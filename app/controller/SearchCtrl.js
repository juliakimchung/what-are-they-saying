"use strict";
app.controller("SearchCtrl", function($scope, $http, $sce, VideoFactory, AuthFactory, SearchTermData, $interpolate, $location) {

    $scope.getVideo = function(val) {
        $http.get('https://www.googleapis.com/youtube/v3/search', {
            params: {
                key: 'AIzaSyDmRXSz9KWkx_GKTCwOhXtyHrFnqBF7u2E',
                part: 'snippet',
                type: 'video',
                q: val+"kpop"
            }
        }).then(function(videoObj) {
            $scope.data = videoObj.data.items;
            $scope.data.forEach(function(video) {
                video.videoID = $sce.trustAsResourceUrl('http://www.youtube.com/embed/' + video.id.videoId);
                console.log(video)
            });
            $scope.toggle = function() {
                $scope.myVar = !$scope.myVar;
            };
        }).catch((error)=>{
          console.log("error",error );
        });
    };
   
     $scope.saveToMyVideos = function(video){
      VideoFactory.saveVideo(video)
      .then(function(){
        $location.url('/#!/collection')
        console.log("video from saveVideos", video );
      }).catch((error)=>{
        console.log("error",error );
      })
     };

});