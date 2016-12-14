"use strict";
app.factory("VideoFactory", ($http, FBCreds, AuthFactory) => {

	let fireUser = AuthFactory.getUser();
	console.log("fireUser", fireUser);

	let getAllSavedVideos = (video) => {
		let videoCollection = [];
		console.log("FBCreds.URL",`${FBCreds.URL}/video.json?orderBy="uid"&equalTo="${fireUser}"` );
		return new Promise((resolve, reject)=> {
		$http.get(`${FBCreds.URL}/video.json?orderBy="uid"&equalTo="${fireUser}"`)
		// uid from the firebase indexOn
		.then((results)=> {
			let videoDataArray = results.data;
			console.log("videoDataArray",videoDataArray );
			Object.keys(videoDataArray).forEach((key)=> {
				videoDataArray[key].id = key;
				videoCollection.push(videoDataArray[key]);
			});
				resolve(videoCollection);
				console.log("videoCollection from getAllSavedVideos", videoCollection );

		})
			.catch((error)=> {
				console.log("error",error );
				});
});
}

 let saveVideo = function(video, user){
 		//console.log("FBCreds.URL", `${FBCreds.URL}`, "FBCreds.URL", "${FBCreds.URL}");

		let newVideo = {
			title: video.snippet.title,
			videoId: video.id.videoId,
			uid: fireUser,
			pic: video.snippet.thumbnails.medium,
			lyrics: ""
		}
		console.log("currentUser", fireUser );
		return new Promise((resolve, reject)=> {
			$http.post(`${FBCreds.URL}/video.json`, angular.toJson(newVideo))
			.then((itemObject) => {
				resolve(itemObject);
				console.log("itemObject after saveVideo promise", itemObject);
				})
				.catch((error)=> {
				console.log("error", error);
			});
		});
	}

	let getSingleVideo = (videoId)=> {
		console.log("videoId from getSingleVideo", videoId);
		return new Promise((resolve, reject)=> {
		$http.get(`${FBCreds.URL}/video/${videoId}.json`)
			.then((result) =>{
				console.log("get single video result", result);
			 resolve(result);
			}).catch((result)=> {
				console.log("error",result);
			})
		});
	};
	// `${FBCreds.URL}/video/${videoId}.json`
	// `${FBCreds.URL}/${fireUser}/video/${videoId}.json`
// `${FBCreds.URL}/video.json?orderBy="uid"&equalTo="${fireUser}"`
	let updateSingleVideo = (videoId, lyricVideo)=> {
			return new Promise((resolve, reject) =>{
				$http.patch(`${FBCreds.URL}/video/${videoId}.json`, angular.toJson(lyricVideo))
				.then((result)=> {
					resolve(result);
				})
				.catch((error)=> {
					console.log("error",error );
				})
			});
	};
	//${FBCreds.URL}${fireUser}/video/${videoId}.json
	// ${fireUser}/video/${videoId}.json
// `${FBCreds.URL}/video/${videoId}.json`
	let deleteVideo = (videoId) => {
		return new Promise((resolve, reject)=> {
			$http.delete(`${FBCreds.URL}/video/${videoId}.json`)
			.then((obj)=> {
				resolve(obj);
			})
			.catch((error)=> {
				console.log("error",error );
			})
		});
	};

	return { updateSingleVideo, getAllSavedVideos, saveVideo, deleteVideo, getSingleVideo};

});