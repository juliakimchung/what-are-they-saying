 "use strict";
app.controller("ListHomeVideoCtrl", function($scope, $sce, $routeParams, $location, $interpolate, VideoFactory, AuthFactory, SearchTermData) {
	$scope.searchText = SearchTermData;
    $scope.selectedVideos = [];
  $scope.watchHomeVideos = function(){
    VideoFactory.getAllReviewVideos()
    .then((videoData)=> {
    	videoData.forEach((video) => {
 				if(video.reviewCount > 3){
 				let videoForHome = video
 					$scope.selectedVideos.push(videoForHome);
     			console.log("selectedVideos from ListHomeVideoCtrl", $scope.selectedVideos );
    			$scope.$apply();
 				}
 			});

		});
	};
	$scope.watchHomeVideos();
});
            
    	