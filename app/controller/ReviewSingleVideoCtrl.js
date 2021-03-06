"use strict";
app.controller("ReviewSingleVideoCtrl", function($scope, $sce, $routeParams, $location, $interpolate, VideoFactory, AuthFactory, SearchTermData) {
    console.log("ReviewSingleVideoCtrl", $routeParams.videoId);
    $scope.currentVideo = {};
    $scope.currentPath = "";
    $scope.currentVideo.reviewCount = 0;
    $scope.buttonClicked = false;
    $scope.watchForReview = () => {
        VideoFactory.getSingleVideo($routeParams.videoId)
            .then((result) => {
                let videoToPlay = result.data.videoId;
                console.log("result from ReviewSingleVideoCtrl", result);
  
                $scope.currentVideo = result.data;
                $scope.currentPath = $sce.trustAsResourceUrl(`http://www.youtube.com/embed/${videoToPlay}`)
                console.log("$scope.currentPath", $scope.currentPath);
                $scope.$apply();

            });       
    };
    $scope.buttonClicked = () => {
        $scope.currentVideo.reviewCount++;
        $scope.buttonClicked = true;

        console.log("$scope.reviewCount from buttonClicked()", $scope.reviewCount);
         VideoFactory.updateSingleVideo($routeParams.videoId, $scope.currentVideo)
        .then(function(){
            console.log("$scope.currentVideo from reviewSingleVideo function", $scope.currentVideo);
        })
        
        };
  

   $scope.watchForReview();
});

