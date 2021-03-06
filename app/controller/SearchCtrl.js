"use strict";
app.controller("SearchCtrl", function($scope, $http, $sce, VideoFactory, AuthFactory, SearchTermData, $interpolate, $location) {

    $scope.getVideo = function(value) {
        $http.get('https://www.googleapis.com/youtube/v3/search', {
            params: {
                key: 'AIzaSyAm_YmmR7imdzOuorlfTRcRIftBAmpqEy0',
                part: 'snippet',
                type: 'video',
                q: value+"kpop"
            }
        })
        .then(function(videoObj) {
            $scope.data = videoObj.data.items;
            $scope.data.forEach(function(video) {
                video.videoID = $sce.trustAsResourceUrl('http://www.youtube.com/embed/' + video.id.videoId);
                console.log("video from getVideo", video)
            });
            $scope.toggle = function() {
                $scope.myVar = !$scope.myVar;
            };
        })
        .catch((error)=>{
          console.log("error",error );
        });
    };

     $scope.saveToMyVideos = function(video){
      VideoFactory.saveVideo(video)
      .then(function(){
        console.log("video from saveVideos", video );
      })
      .catch((error)=>{
        console.log("error",error );
      })
    };

});
