"use strict";
app.controller("AddReviewVideoCtrl", function($scope, $sce, $routeParams, $location, $interpolate, VideoFactory, AuthFactory, SearchTermData) {
$scope.searchText = SearchTermData;
  $scope.watchForReview = function(){
    VideoFactory.getAllReviewVideos()
    .then((videoData)=> {
      console.log("videoData from watchForReview", videoData);
      $scope.data = videoData;
      $scope.$apply();
    })

  }
   $scope.watchForReview();
});

  // $scope.currentVideos = [];
  // $scope.currentPath = "";

  // $scope.watchForReview = () => {
  // VideoFactory.getAllSavedVideos()
  //     .then((result) => {
  //             for (var i = 0; i < result.length; i++) {
  //                 if (result[i].review === true) {
  //                     let videoToReview = result[i].videoId;
  //                     console.log("result from AddReviewVideoCtrl", videoToReview);
  //                     // 
              //         $scope.currentVideos.push(videoToReview);
              //         console.log("$scope.currentVideos from AddReviewVideoCtrl", $scope.currentVideos);
              //     }
              // }
               // 
              
              // $scope.currentVideos.forEach(function(currentVideo) {
              //     currentVideo = $sce.trustAsResourceUrl(`http://www.youtube.com/embed/${currentVideo.videoId}`)
              
              // });

              // console.log("videos from AddReviewVideoCtrl", $scope.currentVideos);

              // $scope.toggle = function() {
              //         $scope.myVar = !$scope.myVar;
              //     }
                  // console.log("currentVideo from AddReviewVideoCtrl", $scope.currentVideo);
      //         $scope.$apply();
      // });


          
