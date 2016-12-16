"use strict";
app.controller("NavCtrl", function($scope, SearchTermData, AuthFactory){
	AuthFactory.logoutUser();
	$scope.searchText = SearchTermData;
	$scope.navItems = [

		{name: 'Login/Register',
		 url: '#/login'
	},
		{name: 'Logout',
		 url: '#/logout'

	},
		{name: 'All Videos',
		 url: '#/videos/list'
	},
		{name: 'My Video Collection',
		 url: '#/video/collection'

	},
		{name: 'Review',
		 url: '#/video/review'
	},

		{name: 'Search',
		 url: '#/videos/search'
	}

]
})
