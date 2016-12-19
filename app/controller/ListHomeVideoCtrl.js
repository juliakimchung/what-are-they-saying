// "use strict";
app.controller("ListHomeVideoCtrl", function($scope, $sce, $routeParams, $location, $interpolate, VideoFactory, AuthFactory, SearchTermData) {
		$scope.selectedVideos = [];
  $scope.watchHomeVideos = function(){
    VideoFactory.getAllReviewVideos()
    .then((videoData)=> {
    	console.log("videoData from watchHomeVideos", videoData);

    	for(let i = 0; i < videoData.length; i++){
    		if(videoData[i].reviewCount > 3){
    			let videoForHome = videoData[i].videoId;
    			$scope.selectedVideos.push(videoForHome);
    			console.log("videoForHome from ListHomeVideoCtrl", $scope.selectedVideos);

    		}
    	$scope.selectedVideos = videoData;
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
  //             for (var i = 0; i < result.length; i++) {
  //                 if (result[i].review === true) {
  //                     let videoToReview = result[i].videoId;
  //                     console.log("result from AddReviewVideoCtrl", videoToReview);
  //                     // 
              //         $scope.currentVideos.push(videoToReview);
              //         console.log("$scope.currentVideos from AddReviewVideoCtrl", $scope.currentVideos);
              //     }
              // }
               // $scope.currentVideos = result;
