"use strict";
app.controller("EditVideoCtrl", function($scope, $sce, $routeParams, $location, $interpolate, VideoFactory, AuthFactory, SearchTermData) {
    console.log("EditVideoCtrl", $routeParams.videoId);

    $scope.currentVideo = {};
    $scope.currentPath = "";
    $scope.watchYourVideo = () => {
        VideoFactory.getSingleVideo($routeParams.videoId)
            .then((response) => {
            		$routeParams.videoId = response.data.videoId;
                console.log("response from EditVideoCtrl", response);
                $scope.currentVideo = response.data;
                $scope.currentPath = $sce.trustAsResourceUrl(`http://www.youtube.com/embed/${$routeParams.videoId}`)
                console.log("$scope.currentPath", $scope.currentPath);
                $scope.$apply();

            });

            	// `http://www.youtube.com/embed/${$routeParams.videoId}`
   	};
    $scope.editVideo = function(lyricVideo) {
        let videoID = $routeParams.videoId;
        console.log("lyricVideo", lyricVideo);
        VideoFactory.updateSingleVideo(videoID, lyricVideo)
            .then(function() {
                console.log("lyricVideo", lyricVideo);
            })
            .then(function() {
                $location.url('/#!/edit/:videoId');
            }).then(function() {
                console.log("videoID", videoID);
            })
    };

     $scope.watchYourVideo();
});
