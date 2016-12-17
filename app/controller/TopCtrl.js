"use strict";
app.controller("TopCtrl", function($scope, $location, $window, AuthFactory){
	$scope.isLoggedIn = false;
	let currentUser = null;

	firebase.auth().onAuthStateChanged(function(user){
		if(user){
			currentUser = user.uid;
			$scope.isLoggedIn = true;
			console.log("currentUser logged in?", user.uid, $scope.isLoggedIn);
			$window.location.href = "/#!/video";
		}else {
			currentUser = null;
			$scope.isLoggedIn = false;
			$window.location.href = "/#!/login";
		}
	});

	$scope.getUser = function(){
		return currentUser;
	};

	$scope.logout = function(){
		AuthFactory.loggoutUser()
		.then(function(data){
			console.log("logged out", data );
	  });
	};
	
});


























