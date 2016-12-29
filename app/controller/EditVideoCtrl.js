"use strict";
app.controller("EditVideoCtrl", function($scope, $sce, $routeParams, $location, $interpolate, VideoFactory, AuthFactory, SearchTermData) {
    console.log("EditVideoCtrl", $routeParams.videoId);
    $scope.searchText = SearchTermData;
    $scope.currentVideo = {};
    $scope.currentPath = "";
    $scope.watchYourVideo = () => {
        VideoFactory.getSingleVideo($routeParams.videoId)
            .then((response) => {
                let videoToPlay = response.data.videoId;
                console.log("response from EditVideoCtrl", response);
  
                $scope.currentVideo = response.data;
                $scope.currentPath = $sce.trustAsResourceUrl(`http://www.youtube.com/embed/${videoToPlay}`)
                console.log("$scope.currentPath", $scope.currentPath);
                $scope.$apply();

            });       
    };
    $scope.editVideo = function() {
      VideoFactory.updateSingleVideo($routeParams.videoId, $scope.currentVideo)
            .then(function() {
             console.log("$scope.currentVideo from edit Video",$scope.currentVideo);
            })
            // .then(function() {
            //   $location.url('/#!/collection');
            // })
      
    };
    
   $scope.watchYourVideo();
});

