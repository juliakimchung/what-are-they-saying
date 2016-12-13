"use strict";
app.controller("EditVideoCtrl", function($scope, $sce, $routeParams, $location, $interpolate, VideoFactory, AuthFactory, SearchTermData){
	console.log("EditVideoCtrl",$routeParams.videoId );

	$scope.currentVideo ={};
	$scope.currentPath="";
$scope.watchYourVideo = () => {
	VideoFactory.getSingleVideo($routeParams.videoId)
		.then((response)=> {
			$scope.currentVideo = response;
			$scope.currentPath=$sce.trustAsResourceUrl('http://www.youtube.com/embed/' + $scope.currentVideo.videoId)
				console.log("$scope.currentPath",$scope.currentPath);

});
}	
	$scope.editVideo = function(lyricVideo){
		let videoID = $routeParams.videoId;
		console.log("lyricVideo",lyricVideo );
			VideoFactory.updateSingleVideo(videoID, lyricVideo)
			.then(function() {
				console.log("lyricVideo",lyricVideo );
			})
			.then(function(){
			$location.url('/collection');
		})
	};
});
