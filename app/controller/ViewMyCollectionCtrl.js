"use strict";
app.controller("ViewMyCollectionCtrl", function($scope, $sce, VideoFactory, $location, AuthFactory, SearchTermData){

	$scope.searchText = SearchTermData;

	VideoFactory.getAllSavedVideos()
		.then((videoData)=> {
			$scope.data = videoData;
			$scope.$apply();
			console.log("videoData from ViewMyCollectionCtrl", videoData );

		});	
		 
		
	$scope.remove = function(videoId){
		VideoFactory.deleteVideo(videoId)
		.then ((response)=>{
			console.log("videoId from remove function", videoId );
			VideoFactory.getAllSavedVideos()
			.then((videoData)=> {
				$scope.data = videoData;
				$scope.$apply();
		console.log("data from SaveToMyVideo", videoData );
			});
		});
	};
});