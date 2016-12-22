"use strict";
app.controller("LoginCtrl", function($scope, AuthFactory, $window){
	AuthFactory.logoutUser();

	$scope.account = {
		email: "jul@me.com",
		password: "123456",
		
	};
	$scope.register = () => {
		AuthFactory.createUser($scope.account)
		.then((userData)=> {
			$scope.login();
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