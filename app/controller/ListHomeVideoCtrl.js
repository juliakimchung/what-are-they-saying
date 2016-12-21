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
            
    	// console.log("videoData from ListHomeVideoCtrl", videoData);
    	// for(let i = 0; i < videoData.length; i++){
    	// 	if(videoData[i].reviewCount > 3){
    	// 		let videoForHome = videoData[i].id;
    	// 		$scope.selectedVideos.push(videoForHome);
    	// 		console.log("videoForHome from ListHomeVideoCtrl", $scope.selectedVideos);

    			
    	// 	}
     // $scope.$apply()
    	// }
 //    };
 //    });
	// }

