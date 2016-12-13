"use strict";
app.controller("ViewMyCollectionCtrl", function($scope, $sce, VideoFactory, $location, AuthFactory, SearchTermData){

	$scope.searchText = SearchTermData;

	VideoFactory.getAllSavedVideos()
		.then((videoData)=> {
			$scope.data = videoData;
			$scope.$apply();
			console.log("videoData", videoData );
			
		});
		 
		
	$scope.remove = function(videoId){
		VideoFactory.deleteVideo(videoId)
		.then ((response)=>{
			VideoFactory.getAllSavedVideos()
			.then((videoData)=> {
				$scope.data = videoData;
				$scope.$apply();
		console.log("data from SaveToMyVideo", videoData );
			})

		})
	};
});