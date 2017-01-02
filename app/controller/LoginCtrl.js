"use strict";
app.controller("LoginCtrl", function($scope, AuthFactory, $window){
	AuthFactory.logoutUser();

	$scope.account = {
		email: "rody@me.com",
		password: "123456",
		username: "ravenclaw"
	};
	$scope.register = () => {
		AuthFactory.createUser($scope.account)
		.then((userData)=> {
			// $scope.login();
			console.log("userData after register", userData);
			if(userData){
				$scope.login();
			}
			let userObj = {
				email: userData.email,
				uid: userData.uid,
				displayName: $scope.account.username
			}
			AuthFactory.saveUserToFB(userObj)
			.then(()=> {
				console.log("user saved from LoginCtrl", userObj);
			})
			.catch((error)=> {
				
				console.log("error creating user account" );
				$scope.$apply();
			})
		});
	};
	$scope.login =() => {
		AuthFactory.loginUser($scope.account)
		.then((user) => {
			 console.log("user after login", user );
			$window.location.href = '/#!/collection';
		});
	};
});