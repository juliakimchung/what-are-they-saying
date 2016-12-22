"use strict";
app.controller("FooterCtrl", function($scope, AuthFactory){
	//$scope.AuthFactory= logoutUser();
	$scope.footerItems = [
	{name: "copyright",
		App: "K-PopTranslateApp"
	}
	]
})