"use strict";
let app = angular.module("K-PopTranslateApp", ["ngRoute"]);
app.config(function($routeProvider){
let isAuth = (AuthFactory) => new Promise((resolve, reject)=> {
	AuthFactory.isAuthenticated()
	.then((userExists)=> {
		if(userExists){
			resolve()
		}else{
			reject();
		}
	});
});
	
	$routeProvider
	// .when("/", {
	// 	templateUrl: "partials/Login.html",
	// 	controller: "LoginCtrl"
	// })
	.when('/login', {
		templateUrl: 'partials/Login.html',
		controller: 'LoginCtrl'
	})
    .when('/video', {
    	templateUrl: 'partials/ListAllVideo.html',
    	controller: 'ListAllVideoCtrl',
    	resolve: {isAuth}
    })
    .when('/search', {
    	templateUrl: 'partials/Search.html',
    	controller: 'SearchCtrl',
    	resolve: {isAuth}
    })
    .when ('/collection', {
    	templateUrl: 'partials/ListMyCollection.html',
    	controller: 'ViewMyCollectionCtrl',
    	resolve: {isAuth}
    })
    .when('/collection/:videoId',{
    	templateUrl: 'partials/SingleVideoDetail.html',
    	controller: 'EditVideoCtrl',
    	resolve: {isAuth}
    })
    
	.otherwise("/");

});

app.run(($location, FBCreds) => {
	let creds = FBCreds;
	let authConfig = {
		apiKey: creds.key,
		authDomain: creds.authDomain
	};
	firebase.initializeApp(authConfig);
});