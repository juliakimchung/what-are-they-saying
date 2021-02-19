#########################################################################							
# TARGET :	EDWCDM.Bed_Management_Detail_Cerner		#						
# SOURCE :	EDWCDM_Staging.Bed_Management_Cerner_STG	        #
# 									#	
# Author		Date		History 			#
# 									#
# Julia Kim             02/16/2021     NUD-1048                      #					
#########################################################################								
								
bteq << EOF >> $1;								
								
.RUN FILE /etl/ST/CDM/LOGON/CDM_ED/CM_LOGON;	

SET QUERY_BAND = 'App=CDM_ED_ETL; Job=J_CDM_ED_Bed_Management_Detail_Cerner;' FOR SESSION;

.IF ERRORCODE <> 0 THEN .QUIT ERRORCODE;

CALL dbadmin_procs.collect_stats_table ('EDWCDM_STAGING','Bed_Management_Cerner_STG');


CREATE MULTISET VOLATILE TABLE Additional_Transfers AS
(
WITH undo_transfer_patients AS
(

SELECT DISTINCT EE.Patient_DW_Id
,EE.Event_User_Mnemonic_CS
,EE.Event_Eff_From_Date_Time
,EE.Event_Eff_To_Date_Time
,EE.Event_Location_Mnemonic_CS
,EE.Event_Room_Mnemonic_CS
,EE.Event_Bed_Num_Code
,EE.Previous_Location_Mnemonic_CS
,EE.Previous_Room_MNemonic_CS
,EE.Previous_Bed_Num_Code
,EE.Source_System_Code

FROM EDWCDM_BASE_VIEWS.Encounter_Event EE


LEFT JOIN EDWCDM_Base_Views.ENCNT_DTL  enc
ON EE.Patient_DW_Id = enc.Patient_DW_Id

WHERE EE.Source_System_Code = 'F'
AND EE.EVENT_CODE = 'A12'
AND enc.ADMT_TS < Current_Timestamp(0)
AND enc.ADMT_TS >=current_timestamp - interval '731' day
AND enc.Vld_To_TS = '9999-12-31 00:00:00'
AND enc.SRC_SYS_REF_CD = 'Cerner'


AND  EE.Event_Location_Mnemonic_CS is not null

),
transfer_patients AS
(
SELECT DISTINCT
EE.Patient_DW_Id
,EE.Event_Date_Time
,EE.Event_Sequence_Id
,EE.Pat_Acct_Num
,EE.Company_Code
,EE.Coid
,EE.Event_Code
,EE.Event_Eff_From_Date_Time
,EE.Event_Eff_To_Date_Time
,EE.Event_Status_Code
,EE.Event_User_Mnemonic_CS
,EE.Event_Location_Mnemonic_CS
,EE.Event_Room_Mnemonic_CS
,EE.Event_Bed_Num_Code
,EE.Previous_Location_Mnemonic_CS
,EE.Previous_Room_MNemonic_CS
,EE.Previous_Bed_Num_Code
,EE.Source_System_Code
,enc.ADMT_TS AS Admission_Date_Time

FROM EDWCDM_BASE_VIEWS.Encounter_Event EE

LEFT JOIN EDWCDM_Base_Views.ENCNT_DTL  enc
ON EE.Patient_DW_Id = enc.Patient_DW_Id


WHERE EE.Source_System_Code = 'F'
AND EE.EVENT_CODE = 'A02'
AND enc.ADMT_TS < Current_Timestamp(0)
AND enc.ADMT_TS >=current_timestamp - interval '731' day
--AND enc.Vld_To_TS = '9999-12-31 00:00:00'
AND enc.SRC_SYS_REF_CD = 'Cerner'



AND  EE.Event_Location_Mnemonic_CS is not null
--and EE.patient_dw_id = 201319900009095706
AND NOT EXISTS ( sel 1 from undo_transfer_patients utp
WHERE EE.Patient_DW_Id = utp.Patient_DW_Id
AND Coalesce(EE.Event_Location_Mnemonic_CS, '~') = Coalesce(utp.Previous_Location_Mnemonic_CS, '~')
AND Coalesce(EE.Event_Room_Mnemonic_CS , '~')= Coalesce(utp.Previous_Room_MNemonic_CS, '~')
AND Coalesce(EE.Event_Bed_Num_Code , '~') = Coalesce(utp.Previous_Bed_Num_Code , '~')
AND EE.Event_Eff_To_Date_Time < utp.Event_Eff_From_Date_Time
)
)
SELECT 
Row_Number() over (order by EE.Patient_DW_Id ) as Row_num 
,EE.Patient_DW_Id
,EE.Event_Date_Time
,EE.Event_Sequence_Id
,EE.Pat_Acct_Num
,EE.Company_Code
,EE.Coid
,EE.Event_Code
,EE.Event_Eff_From_Date_Time
,EE.Event_Eff_To_Date_Time
,EE.Event_Status_Code
,EE.Event_User_Mnemonic_CS
,EE.Event_Location_Mnemonic_CS
,EE.Event_Room_Mnemonic_CS
,EE.Event_Bed_Num_Code
,EE.Previous_Location_Mnemonic_CS
,EE.Previous_Room_MNemonic_CS
,EE.Previous_Bed_Num_Code
,EE.Source_System_Code
,tp.Admission_Date_Time

FROM EDWCDM_BASE_VIEWS.Encounter_Event EE


LEFT JOIN transfer_patients tp
ON EE.Patient_DW_Id = tp.Patient_DW_Id
AND EE.Event_Date_Time = tp.Event_Date_Time
AND EE.Event_Code = tp.Event_Code
AND EE.Event_Eff_From_Date_Time = tp.Event_Eff_From_Date_Time
AND EE.Event_Eff_To_Date_Time = tp.Event_Eff_To_Date_Time

WHERE tp.patient_dw_id is not null
--and  EE.patient_dw_id = 210479900006080314
--and EE.Patient_DW_ID = 210459900020004508
) WITH DATA PRIMARY INDEX  (Row_num) ON COMMIT PRESERVE ROWS;

;
COLLECT STATISTICS COLUMN (Patient_DW_Id
,Event_Date_Time
,Event_Sequence_Id
,Pat_Acct_Num
,Company_Code
,Coid
,Event_Code
,Event_Eff_From_Date_Time) ON Additional_Transfers ;



 CREATE MULTISET VOLATILE TABLE Cerner_Admit AS
(
 WITH ENCNT_DTL_Admission  AS
 (
 SELECT
 ed.ADMT_TS AS ADMT_TS, 
 ed.Patient_DW_ID,  
 ed.PTNT_STS_REF_CD,
 ed.PTNT_CLASS_REF_CD
 FROM EDWCDM_Base_Views.ENCNT_DTL  ed
 
 WHERE  ed.Vld_To_TS = '9999-12-31 00:00:00'
 AND ed.SRC_SYS_REF_CD = 'Cerner'

 )
 
 SELECT
 Row_Number() over (order by EE.Patient_DW_Id ) as Row_num ,
 EE.Patient_DW_ID ,
 EE.Event_Date_Time ,
 EE.Event_Sequence_Id,
 EE.Pat_Acct_Num,
 EE.Company_Code,
 EE.Coid,
 EE.Event_Eff_From_Date_Time ,
 EE.Event_Eff_To_Date_Time,
 EE.Event_Location_Mnemonic_CS ,
 EE.Event_Room_Mnemonic_CS ,
 EE.Event_Bed_Num_Code ,
 EE.Event_Code ,
 EDA.ADMT_TS ,
 EDA.PTNT_STS_REF_CD ,
 EDA.PTNT_CLASS_REF_CD 
 
 FROM EDWCDM_Base_Views.Encounter_Event EE 
LEFT JOIN  ENCNT_DTL_Admission  EDA
ON EE.Patient_DW_ID = EDA.Patient_DW_Id 
AND EE.Event_Date_Time = EDA.ADMT_TS 
 --WHERE EE.Patient_DW_ID = 210389900018230609 
WHERE EDA.PTNT_STS_REF_CD is not null 
AND EE.Source_System_Code = 'F'
 QUALIFY ROW_NUMBER() OVER (PARTITION BY EE.Patient_DW_Id ORDER BY Event_Eff_From_Date_Time) = 1
) WITH DATA PRIMARY INDEX  (Row_num) ON COMMIT PRESERVE ROWS;

COLLECT STATISTICS COLUMN (Patient_DW_Id
,Event_Date_Time
,Event_Sequence_Id
,Pat_Acct_Num
,Company_Code
,Coid
,Event_Code
,Event_Eff_From_Date_Time) ON Cerner_Admit ;


CREATE MULTISET VOLATILE TABLE Cerner_Discharge AS
(
 WITH ENCNT_DTL_Discharged  AS
 (
 SELECT
 ed.DSCRG_TS AS DSCRG_TS, 
 ed.Patient_DW_ID,  
 ed.PTNT_STS_REF_CD,
 ed.PTNT_CLASS_REF_CD
 FROM EDWCDM_Base_Views.ENCNT_DTL  ed
 
 WHERE ed.Vld_To_TS = '9999-12-31 00:00:00'
 AND ed.SRC_SYS_REF_CD = 'Cerner'
 )
 
 SELECT
 Row_Number() over (order by EE.Patient_DW_Id ) as Row_num ,
 EE.Patient_DW_ID ,
 EE.Event_Date_Time ,
 EE.Event_Sequence_Id,
 EE.Pat_Acct_Num,
 EE.Company_Code,
 EE.Coid,
 EE.Event_Eff_From_Date_Time ,
 EE.Event_Eff_To_Date_Time,
 EE.Event_Location_Mnemonic_CS ,
 EE.Event_Room_Mnemonic_CS ,
 EE.Event_Bed_Num_Code ,
 EE.Event_Code ,
 EDD.DSCRG_TS ,
 EDD.PTNT_STS_REF_CD ,
 EDD.PTNT_CLASS_REF_CD 
 
FROM EDWCDM_Base_Views.Encounter_Event EE 
LEFT JOIN  ENCNT_DTL_Discharged  EDD
ON EE.Patient_DW_ID = EDD.Patient_DW_Id 
AND EE.Event_Date_Time = EDD.DSCRG_TS 
 --WHERE EE.Patient_DW_ID = 210389900018230609 
WHERE EDD.PTNT_STS_REF_CD is not null 
AND EE.Source_System_Code = 'F'
QUALIFY ROW_NUMBER() OVER (PARTITION BY EE.Patient_DW_Id ORDER BY Event_Eff_From_Date_Time) = 1
) WITH DATA PRIMARY INDEX  (Row_num) ON COMMIT PRESERVE ROWS;

COLLECT STATISTICS COLUMN (Patient_DW_Id
,Event_Date_Time
,Event_Sequence_Id
,Pat_Acct_Num
,Company_Code
,Coid
,Event_Code
,Event_Eff_From_Date_Time) ON Cerner_Discharge ;


DELETE FROM EDWCDM_STAGING.Bed_Management_Detail_Cerner_WRK;
INSERT INTO EDWCDM_STAGING.Bed_Management_Detail_Cerner_WRK
(
Patient_DW_Id,
Pat_Acct_Num,
Company_Code,
COID,
Admission_Date_Time,
Transfer_Audit_Date_Time,
Patient_Transfer_In_Date_Time,
Transfer_Sequence_Id,
Transfer_In_Location_Mnem_CS,
Transfer_In_Room_Mnem_CS,
Transfer_In_Bed_Num_Code,
Transfer_Out_Location_Mnem_CS,
Transfer_Out_Room_Mnem_CS,
Transfer_Out_Bed_Num_Code,
Bed_Request_Date_Time,
Bed_Request_Filed_Date_Time,
Bed_Assignment_Date_Time,
Bed_Assignment_Filed_Date_Time,
Patient_Transfer_Out_Date_Time,
Patient_Discharge_Date_Time,
Discharge_Location_Sw,
Transfer_Same_Location_Sw,
Source_System_Code,
DW_Last_Update_Date_Time
)
SEL
a.Patient_DW_Id,
a.Pat_Acct_Num,
a.Company_Code,
a.COID,
a.Admission_Date_Time,
a.Transfer_Audit_Date_Time,
a.Patient_Transfer_In_Date_Time,
a.Transfer_Sequence_Id,
a.Transfer_In_Location_Mnem_CS,
a.Transfer_In_Room_Mnem_CS,
a.Transfer_In_Bed_Num_Code,
CASE WHEN a.Patient_Transfer_Out_Date_Time is null then null ELSE  a.Transfer_Out_Location_Mnem_CS END AS Transfer_Out_Location_Mnem_CS,
CASE WHEN a.Patient_Transfer_Out_Date_Time is null then null ELSE a.Transfer_Out_Room_Mnem_CS END AS Transfer_Out_Room_Mnem_CS,
CASE WHEN a.Patient_Transfer_Out_Date_Time is null then null ELSE a.Transfer_Out_Bed_Num_Code END AS Transfer_Out_Bed_Num_Code,
a.Bed_Request_Date_Time,
a.Bed_Request_Filed_Date_Time,
a.Bed_Assignment_Date_Time,
a.Bed_Assignment_Filed_Date_Time,
a.Patient_Transfer_Out_Date_Time,
a.Patient_Discharge_Date_Time,
a.Discharge_Location_Sw,
CASE WHEN Prev_Patient_Transfer_In_Date_Time is null THEN 0 
			WHEN a.Transfer_In_Location_Mnem_CS =Coalesce(a.Prev_Transfer_Location_Mnem_CS, 'UKN')  THEN 1 
			ELSE 0 
END AS Transfer_Same_Location_Sw,
'F' AS Source_System_Code,
Current_Timestamp(0) AS DW_Last_Update_Date_Time
FROM
(
SEL 
a.Patient_DW_Id,
a.Pat_Acct_Num,
a.Company_Code,
a.COID,
a.Admission_Date_Time,
a.Transfer_Audit_Date_Time,
a.Patient_Transfer_In_Date_Time,
coalesce(MIN(a.Patient_Transfer_In_Date_Time) OVER (Partition BY a.Patient_DW_Id ORDER BY a.Patient_Transfer_In_Date_Time ROWS BETWEEN 1 PRECEDING  and 1 PRECEDING) , null)AS Prev_Patient_Transfer_In_Date_Time,
a.Transfer_Sequence_Id,
a.Transfer_In_Location_Mnem_CS,
Coalesce(a.Transfer_In_Room_Mnem_CS, 'UKN') AS Transfer_In_Room_Mnem_CS,
Coalesce(a.Transfer_In_Bed_Num_Code, 'UKN') AS Transfer_In_Bed_Num_Code,
null AS Previous_Patient_DW_Id,
null AS Previous_Pat_Acct_Num,
LAG (a.Transfer_In_Location_Mnem_CS) OVER (ORDER BY a.Patient_DW_Id ,a.Patient_Transfer_In_Date_Time)  AS Prev_Transfer_Location_Mnem_CS,
LEAD(a.Transfer_In_Location_Mnem_CS) OVER (ORDER BY a.Patient_DW_Id ,a.Patient_Transfer_In_Date_Time)  AS Transfer_Out_Location_Mnem_CS,
LEAD(a.Transfer_In_Room_Mnem_CS) OVER (ORDER BY a.Patient_DW_Id ,a.Patient_Transfer_In_Date_Time)  AS Transfer_Out_Room_Mnem_CS,
LEAD(a.Transfer_In_Bed_Num_Code) OVER (ORDER BY a.Patient_DW_Id ,a.Patient_Transfer_In_Date_Time)  AS Transfer_Out_Bed_Num_Code,
null AS Previous_Transfer_Out_Location_Mnem_CS,
null AS Previous_Transfer_Out_Room_Mnem_CS,
null AS Previous_Transfer_Out_Bed_Num_Code,
a.Bed_Request_Date_Time,
a.Bed_Request_Filed_Date_Time,
a.Bed_Assignment_Date_Time,
a.Bed_Assignment_Filed_Date_Time,
null AS Previous_Patient_Transfer_In_Date_Time,
null AS Previous_Patient_Transfer_Out_Date_Time,
null AS Previous_Patient_Discharge_Date_Time,
coalesce(MIN(a.Patient_Transfer_In_Date_Time) OVER (Partition BY a.Patient_DW_Id ORDER BY a.Patient_Transfer_In_Date_Time ROWS BETWEEN 1 FOLLOWING  and 1 FOLLOWING) , null)AS Patient_Transfer_Out_Date_Time,
disc.DSCRG_TS AS Patient_Discharge_Date_Time,
null AS Bed_Dirty_Date_Time,
null AS  Bed_In_Process_Date_Time,
null AS  Bed_Clean_Date_Time,
null AS  House_Keeping_User_Mnem_CS,
null AS  Bed_Manager_User_Mnem_CS,
null AS  Admit_Service_Code,
null AS  Request_Comment_Text,
CASE WHEN a.Patient_Transfer_In_Date_Time = disc.DSCRG_TS THEN 1 ELSE 0 END  AS Discharge_Location_Sw,
a.Source_System_Code,
a.DW_Last_Update_Date_Time
FROM 
(


SEL 
bmc.Patient_DW_Id,
bmc.Pat_Acct_Num,
bmc.Company_Code,
bmc.COID,
trans1.Admission_Date_Time as Admission_Date_Time,
trans1.Event_Date_Time AS Transfer_Audit_Date_Time,
trans1.Event_Eff_From_Date_Time AS Patient_Transfer_In_Date_Time,
trans1.Event_Sequence_Id AS Transfer_Sequence_Id,
trans1.Event_Location_Mnemonic_CS AS Transfer_In_Location_Mnem_CS,
trans1.Event_Room_Mnemonic_CS AS Transfer_In_Room_Mnem_CS,
trans1.Event_Bed_Num_Code AS Transfer_In_Bed_Num_Code,
bmc.Transfer_Request AS Bed_Request_Date_Time,
bmc.Transfer_Request AS Bed_Request_Filed_Date_Time,
bmc.Transfer_Start AS Bed_Assignment_Date_Time,
bmc.Transfer_Start AS Bed_Assignment_Filed_Date_Time,
bmc.Source_System_Code,
bmc.DW_Last_Update_Date_Time
FROM EDWCDM_STAGING.Bed_Management_Cerner_STG bmc
LEFT JOIN Additional_Transfers trans1
ON bmc.Patient_dw_id = trans1.patient_dw_id
AND CAST(bmc.Transfer_Completed AS DATE) = CAST(trans1.Event_Eff_From_Date_Time AS DATE)
AND HOUR(bmc.Transfer_Completed) = HOUR(trans1.Event_Eff_From_Date_Time)
AND MINUTE(bmc.Transfer_Completed) = MINUTE(trans1.Event_Eff_From_Date_Time)
AND Coalesce(STRTOK(bmc.Destination_Unit,'(',1), '~') = Coalesce(trans1.Event_Location_Mnemonic_CS, '~')
AND bmc.Action_Type = 'Completed'
--AND Coalesce(bmc.Destination_Room , '~')= Coalesce(trans1.Event_Room_MNemonic_CS, '~')
--AND Coalesce(bmc.Destination_Bed , '~') = Coalesce(trans1.Event_Bed_Num_Code , '~')

where trans1.patient_dw_id is not null


UNION 

SEL 
bmc.Patient_DW_Id,
bmc.Pat_Acct_Num,
bmc.Company_Code,
bmc.COID,
trans2.Admission_Date_Time as Admission_Date_Time,
trans2.Event_Date_Time AS Transfer_Audit_Date_Time,
trans2.Event_Eff_From_Date_Time AS Patient_Transfer_In_Date_Time,
trans2.Event_Sequence_Id AS Transfer_Sequence_Id,
trans2.Event_Location_Mnemonic_CS AS Transfer_In_Location_Mnem_CS,
trans2.Event_Room_Mnemonic_CS AS Transfer_In_Room_Mnem_CS,
trans2.Event_Bed_Num_Code AS Transfer_In_Bed_Num_Code,
bmc.Transfer_Request AS Bed_Request_Date_Time,
bmc.Transfer_Request AS Bed_Request_Filed_Date_Time,
bmc.Transfer_Start AS Bed_Assignment_Date_Time,
bmc.Transfer_Start AS Bed_Assignment_Filed_Date_Time,
bmc.Source_System_Code,
bmc.DW_Last_Update_Date_Time
FROM EDWCDM_STAGING.Bed_Management_Cerner_STG bmc

INNER JOIN Additional_Transfers trans2
ON bmc.Patient_dw_id = trans2.patient_dw_id

where bmc.Action_Type = 'Completed'
and trans2.Event_Location_Mnemonic_CS is not null

--and bmc.patient_dw_id = 210469900020224211

UNION


SEL 
bmc.Patient_DW_Id,
bmc.Pat_Acct_Num,
bmc.Company_Code,
bmc.COID,
ca.ADMT_TS AS Admission_Date_Time,
ca.Event_Date_Time AS Transfer_Audit_Date_Time,
ca.Event_Eff_From_Date_Time AS Patient_Transfer_In_Date_Time,
ca.Event_Sequence_Id AS Transfer_Sequence_Id,
ca.Event_Location_Mnemonic_CS AS Transfer_In_Location_Mnem_CS,
ca.Event_Room_Mnemonic_CS AS Transfer_In_Room_Mnem_CS,
ca.Event_Bed_Num_Code AS Transfer_In_Bed_Num_Code,
bmc.Transfer_Request AS Bed_Request_Date_Time,
bmc.Transfer_Request AS Bed_Request_Filed_Date_Time,
bmc.Transfer_Start AS Bed_Assignment_Date_Time,
bmc.Transfer_Start AS Bed_Assignment_Filed_Date_Time,
bmc.Source_System_Code,
bmc.DW_Last_Update_Date_Time
FROM EDWCDM_STAGING.Bed_Management_Cerner_STG bmc

INNER JOIN Cerner_Admit ca
ON bmc.Patient_dw_id = ca.patient_dw_id

where bmc.Action_Type = 'Completed'
and ca.Event_Location_Mnemonic_CS is not null

UNION


SEL 
bmc.Patient_DW_Id,
bmc.Pat_Acct_Num,
bmc.Company_Code,
bmc.COID,
cdc.ADMT_TS AS Admission_Date_Time,
cdc.Event_Date_Time AS Transfer_Audit_Date_Time,
cdc.Event_Eff_From_Date_Time AS Patient_Transfer_In_Date_Time,
cdc.Event_Sequence_Id AS Transfer_Sequence_Id,
cdc.Event_Location_Mnemonic_CS AS Transfer_In_Location_Mnem_CS,
cdc.Event_Room_Mnemonic_CS AS Transfer_In_Room_Mnem_CS,
cdc.Event_Bed_Num_Code AS Transfer_In_Bed_Num_Code,
bmc.Transfer_Request AS Bed_Request_Date_Time,
bmc.Transfer_Request AS Bed_Request_Filed_Date_Time,
bmc.Transfer_Start AS Bed_Assignment_Date_Time,
bmc.Transfer_Start AS Bed_Assignment_Filed_Date_Time,
bmc.Source_System_Code,
bmc.DW_Last_Update_Date_Time
FROM EDWCDM_STAGING.Bed_Management_Cerner_STG bmc

INNER JOIN Cerner_Discharge cdc
ON bmc.Patient_dw_id = cdc.patient_dw_id

where bmc.Action_Type = 'Completed'
and cdc.Event_Location_Mnemonic_CS is not null

) a
LEFT JOIN Cerner_Discharge disc
ON a.patient_dw_id = disc.patient_dw_id
AND a.Transfer_Audit_Date_Time = disc.DSCRG_TS

--where a.patient_dw_id = 203459900026124809
)a
--where a.patient_dw_id = 201329900017030908

;


UPDATE TGT
FROM  cabg_temp.Bed_Management_Detail_Cerner TGT,
EDWCDM_STAGING.Bed_Management_Detail_Cerner_WRK  WRK
SET DW_Last_Update_Date_Time = current_timestamp(0) ,
Admission_Date_Time = WRK.Admission_Date_Time,
Transfer_Out_Location_Mnem_CS =WRK.Transfer_Out_Location_Mnem_CS ,
Transfer_Out_Room_Mnem_CS = WRK.Transfer_Out_Room_Mnem_CS,
Transfer_Out_Bed_Num_Code = WRK.Transfer_Out_Bed_Num_Code,
Bed_Request_Date_Time = WRK.Bed_Request_Date_Time,
Bed_Request_Filed_Date_Time = WRK.Bed_Request_Filed_Date_Time,
Bed_Assignment_Date_Time = WRK.Bed_Assignment_Date_Time,
Bed_Assignment_Filed_Date_Time = WRK.Bed_Assignment_Filed_Date_Time,
Patient_Transfer_Out_Date_Time = WRK.Patient_Transfer_Out_Date_Time,
Patient_Discharge_Date_Time = WRK.Patient_Discharge_Date_Time,
Discharge_Location_Sw = WRK.Discharge_Location_Sw,
Transfer_Same_Location_Sw = WRK.Transfer_Same_Location_Sw

WHERE  WRK.Patient_DW_Id = TGT.Patient_DW_Id
AND WRK.COID = TGT.COID
AND WRK.Transfer_Audit_Date_Time = TGT.Transfer_Audit_Date_Time
AND WRK.Patient_Transfer_In_Date_Time=  TGT.Patient_Transfer_In_Date_Time
AND WRK.Transfer_Sequence_Id = TGT.Transfer_Sequence_Id
AND WRK.Transfer_In_Location_Mnem_CS = TGT.Transfer_In_Location_Mnem_CS
AND Coalesce(WRK.Transfer_In_Room_Mnem_CS, 'UKN') = Coalesce(TGT.Transfer_In_Room_Mnem_CS, 'UKN')
AND Coalesce(WRK.Transfer_In_Bed_Num_Code, 'UKN')  = Coalesce(TGT.Transfer_In_Bed_Num_Code , 'UKN')
AND
(
	COALESCE(WRK.Transfer_Out_Location_Mnem_CS,'UKN') NOT =  COALESCE(TGT.Transfer_Out_Location_Mnem_CS,'UKN')
	OR COALESCE(WRK.Transfer_Out_Room_Mnem_CS,'UKN') NOT =  COALESCE(TGT.Transfer_Out_Room_Mnem_CS,'UKN')
	OR COALESCE(WRK.Transfer_Out_Bed_Num_Code,'UKN') NOT =  COALESCE(TGT.Transfer_Out_Bed_Num_Code,'UKN')
	OR COALESCE( WRK.Admission_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0))) NOT =  COALESCE(TGT.Admission_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))
    	OR COALESCE( WRK.Bed_Request_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0))) NOT =  COALESCE(TGT.Bed_Request_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))
	OR COALESCE( WRK.Bed_Request_Filed_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0))) NOT =  COALESCE(TGT.Bed_Request_Filed_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))
	OR COALESCE( WRK.Bed_Assignment_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0))) NOT =  COALESCE(TGT.Bed_Assignment_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))
	OR COALESCE( WRK.Bed_Assignment_Filed_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0))) NOT =  COALESCE(TGT.Bed_Assignment_Filed_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))
    	OR COALESCE( WRK.Patient_Transfer_Out_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0))) NOT =  COALESCE(TGT.Patient_Transfer_Out_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))
    	OR COALESCE( WRK.Patient_Discharge_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0))) NOT =  COALESCE(TGT.Patient_Discharge_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))
	OR COALESCE(WRK.Discharge_Location_Sw,'UKN') NOT = COALESCE(TGT.Discharge_Location_Sw,'UKN')
	OR COALESCE(WRK.Transfer_Same_Location_Sw ,'UKN') NOT = COALESCE(TGT.Transfer_Same_Location_Sw,'UKN')
	
		
)
;

DELETE FROM cabg_temp.Bed_Management_Detail_Cerner
WHERE Admission_Date_Time < current_timestamp - interval '731' day
;

INSERT INTO cabg_temp.Bed_Management_Detail_Cerner
(
Patient_DW_Id,
Pat_Acct_Num,
Company_Code,
COID,
Admission_Date_Time,
Transfer_Audit_Date_Time,
Patient_Transfer_In_Date_Time,
Transfer_Sequence_Id,
Transfer_In_Location_Mnem_CS,
Transfer_In_Room_Mnem_CS,
Transfer_In_Bed_Num_Code,
Transfer_Out_Location_Mnem_CS,
Transfer_Out_Room_Mnem_CS,
Transfer_Out_Bed_Num_Code,
Bed_Request_Date_Time,
Bed_Request_Filed_Date_Time,
Bed_Assignment_Date_Time,
Bed_Assignment_Filed_Date_Time,
Patient_Transfer_Out_Date_Time,
Patient_Discharge_Date_Time,
Discharge_Location_Sw,
Transfer_Same_Location_Sw,
Source_System_Code,
DW_Last_Update_Date_Time
)
SEL
WRK.Patient_DW_Id,
WRK.Pat_Acct_Num,
WRK.Company_Code,
WRK.COID,
WRK.Admission_Date_Time,
WRK.Transfer_Audit_Date_Time,
WRK.Patient_Transfer_In_Date_Time,
WRK.Transfer_Sequence_Id,
WRK.Transfer_In_Location_Mnem_CS,
WRK.Transfer_In_Room_Mnem_CS,
WRK.Transfer_In_Bed_Num_Code,
WRK.Transfer_Out_Location_Mnem_CS,
WRK.Transfer_Out_Room_Mnem_CS,
WRK.Transfer_Out_Bed_Num_Code,
WRK.Bed_Request_Date_Time,
WRK.Bed_Request_Filed_Date_Time,
WRK.Bed_Assignment_Date_Time,
WRK.Bed_Assignment_Filed_Date_Time,
WRK.Patient_Transfer_Out_Date_Time,
WRK.Patient_Discharge_Date_Time,
WRK.Discharge_Location_Sw,
WRK.Transfer_Same_Location_Sw,
WRK.Source_System_Code,
WRK.DW_Last_Update_Date_Time
FROM EDWCDM_STAGING.Bed_Management_Detail_Cerner_WRK  WRK
WHERE NOT EXISTS ( sel 1 from cabg_temp.Bed_Management_Detail_Cerner TGT
WHERE WRK.Patient_DW_Id = TGT.Patient_DW_Id
AND WRK.COID = TGT.COID
AND WRK.Transfer_Audit_Date_Time = TGT.Transfer_Audit_Date_Time
AND WRK.Patient_Transfer_In_Date_Time=  TGT.Patient_Transfer_In_Date_Time
AND WRK.Transfer_Sequence_Id = TGT.Transfer_Sequence_Id
AND WRK.Transfer_In_Location_Mnem_CS = TGT.Transfer_In_Location_Mnem_CS
AND Coalesce(WRK.Transfer_In_Room_Mnem_CS, 'UKN') = Coalesce(TGT.Transfer_In_Room_Mnem_CS, 'UKN')
AND Coalesce(WRK.Transfer_In_Bed_Num_Code, 'UKN')  = Coalesce(TGT.Transfer_In_Bed_Num_Code , 'UKN')
AND
(
	COALESCE(WRK.Transfer_Out_Location_Mnem_CS,'UKN')  =  COALESCE(TGT.Transfer_Out_Location_Mnem_CS,'UKN')
	AND  COALESCE(WRK.Transfer_Out_Room_Mnem_CS,'UKN')  =  COALESCE(TGT.Transfer_Out_Room_Mnem_CS,'UKN')
	AND COALESCE(WRK.Transfer_Out_Bed_Num_Code,'UKN')  =  COALESCE(TGT.Transfer_Out_Bed_Num_Code,'UKN')
	AND COALESCE( WRK.Admission_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))  =  COALESCE(TGT.Admission_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))
    AND COALESCE( WRK.Bed_Request_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))  =  COALESCE(TGT.Bed_Request_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))
	AND COALESCE( WRK.Bed_Request_Filed_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))  =  COALESCE(TGT.Bed_Request_Filed_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))
	AND COALESCE( WRK.Bed_Assignment_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))  =  COALESCE(TGT.Bed_Assignment_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))
	AND COALESCE( WRK.Bed_Assignment_Filed_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))  =  COALESCE(TGT.Bed_Assignment_Filed_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))
    AND COALESCE( WRK.Patient_Transfer_Out_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))  =  COALESCE(TGT.Patient_Transfer_Out_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))
    AND COALESCE( WRK.Patient_Discharge_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))  =  COALESCE(TGT.Patient_Discharge_Date_Time,cast('1900-01-01 00:00:00' as timestamp(0)))
	AND COALESCE(WRK.Discharge_Location_Sw,'UKN')  = COALESCE(TGT.Discharge_Location_Sw,'UKN')
	AND COALESCE(WRK.Transfer_Same_Location_Sw ,'UKN')  = COALESCE(TGT.Transfer_Same_Location_Sw,'UKN')
	
		
)
)


;
CALL dbadmin_procs.collect_stats_table ('EDWCDM','Bed_Management_Detail_Cerner');

.IF ERRORCODE <> 0 THEN .Quit ERRORCODE;



.EXIT

EOF    
		