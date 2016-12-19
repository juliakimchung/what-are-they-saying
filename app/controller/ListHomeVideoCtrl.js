// "use strict";
app.controller("ListHomeVideoCtrl", function($scope, $sce, $routeParams, $location, $interpolate, VideoFactory, AuthFactory, SearchTermData) {
		$scope.selectedVideos = [];
  $scope.watchHomeVideos = function(){
    VideoFactory.getAllReviewVideos()
    .then((videoData)=> {
    	console.log("videoData from ListHomeVideoCtrl", videoData);
    	for(let i = 0; i < videoData.length; i++){
    		if(videoData[i].reviewCount > 3){
    			let videoForHome = videoData[i].id;
    			$scope.selectedVideos.push(videoForHome);
    			console.log("videoForHome from ListHomeVideoCtrl", $scope.selectedVideos);

    			
    		}
    	//console.log("videoData from watchHomeVideos", videoData);
    	//$scope.$apply()
    	}
 //    	videoData.forEach(video in videoData){
 //    	if(video.reviewCount > 3){
 //      $scope.selectedVideos = video;
 //      $scope.selectedVideos.push(video);
 //      console.log("$scope.selectedVideos from watchHomeVideos", $scope.selectedVideos);
 //    }
 //     $scope.selectedVideos = videoData;
 //      $scope.$apply();
 //    };
 //    });
	// }

		});
	};
	$scope.watchHomeVideos();
});
            