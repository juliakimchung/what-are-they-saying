"use strict";
app.controller("AddReviewVideoCtrl", function($scope, $sce, $routeParams, $location, $interpolate, VideoFactory, AuthFactory, SearchTermData) {

  // $scope.currentVideos = [];
  // $scope.currentPath = "";
  $scope.searchText = SearchTermData;
  // VideoFactory.watchForReview = () => {
  VideoFactory.getAllReviewVideos()
      .then((videoData) => {
        $scope.data = videoData;
        $scope.$apply();
        console.log("videoData from AddReviewVideoCtrl",videoData );

      });

  

});
//               for (var i = 0; i < result.length; i++) {
//                   if (result[i].review === true) {
//                       let videoToReview = result[i].videoId;
//                       console.log("result from AddReviewVideoCtrl", videoToReview);
//                       // $scope.currentVideos = videoToReview;
//                       $scope.currentVideos.push(videoToReview);
//                       console.log("$scope.currentVideos from AddReviewVideoCtrl", $scope.currentVideos);
//                   }
//               }
//               // $scope.currentVideos = result;
              
//               $scope.currentVideos.forEach(function(currentVideo) {
//                   currentVideo = $sce.trustAsResourceUrl(`http://www.youtube.com/embed/${currentVideo.videoId}`)
              
//               });
//               console.log("videos from AddReviewVideoCtrl", $scope.currentVideos);

//               // $scope.toggle = function() {
//               //         $scope.myVar = !$scope.myVar;
//               //     }
//                   // console.log("currentVideo from AddReviewVideoCtrl", $scope.currentVideo);
//               $scope.$apply();
//       });


//           // $scope.reviewVideo = function(){
//           //     VideoFactory.updateSingleVideo($routeParams.videoId, $scope.currentVideo)
//           //     .then(function(){
//           //         console.log("$scope.currentVideo from reviewVideo function", $scope.currentVideo);
//           //     })
//           //     .then(function(){
//           //         $location.url('/#!/review/:videoId')
//           //     })
//           // };
//   }
//           $scope.watchForReview();
// });
