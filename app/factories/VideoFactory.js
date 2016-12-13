"use strict";
app.factory("VideoFactory", ($http, FBCreds, AuthFactory) => {

	let fireUser = AuthFactory.getUser();
	console.log("fireUser", fireUser);

	let getAllSavedVideos = (video) => {
		let videoCollection = [];
		console.log("FBCreds.URL",`${FBCreds.URL}/video.json?orderBy="uid"&equalTo="${fireUser}"` );
		return new Promise((resolve, reject)=> {
		$http.get(`${FBCreds.URL}/video.json?orderBy="uid"&equalTo="${fireUser}"`)
		// uid from the firebase indexOn
		.then((results)=> {
			let videoDataArray = results.data;
			console.log("videoDataArray",videoDataArray );
			Object.keys(videoDataArray).forEach((key)=> {
				videoDataArray[key].id = key;
				videoCollection.push(videoDataArray[key]);
			});
				resolve(videoCollection);
				console.log("videoCollection from getAllSavedVideos", videoCollection );

		})
			.catch((error)=> {
				console.log("error",error );
				});
});
}


// .then((videoDataArray)=> {
// 			let videoCollection = videoDataArray;
// 			Object.keys(videoCollection).forEach((key)=> {
// 				console.log("key", key);
// 				videoCollection[key].id = key;
// 				items.push(videoCollection[key]);
// 			});


 let saveVideo = function(video, user){
 		console.log("FBCreds.URL", `${FBCreds.URL}`, "FBCreds.URL", "${FBCreds.URL}");

		let newVideo = {
			title: video.snippet.title,
			videoId: video.id.videoId,
			uid: fireUser,
			pic: video.snippet.thumbnails.medium,
			lyrics: ""
		}
		console.log("currentUser", fireUser );
		return new Promise((resolve, reject)=> {
			$http.post(`${FBCreds.URL}/video.json`, angular.toJson(newVideo))
			.then((itemObject) => {
				resolve(itemObject);
				console.log("itemObject after saveVideo promise", itemObject);
				})
				.catch((error)=> {
				console.log("error", error);
			});
		});
	}

	let getSingleVideo = (video)=> {
		return new Promise((resolve, reject)=> {
			$http.get(`${FBCreds.URL}/video/videoId.json`)
			.then((result) =>{
				resolve(result);
			}).catch((result)=> {
				console.log("error",result);
			})
		})
	}

	let updateSingleVideo = (videoId, lyricVideo)=> {
			return new Promise((resolve, reject) =>{
				$http.patch('${FBCreds.URL}/video/${videoId}.json', angular.toJson(lyricVideo))
				.then((result)=> {
					resolve(result);
				})
				.catch((error)=> {
					console.log("error",error );
				})
			});
	};

	let deleteVideo = (videoId) => {
		return new Promise((resolve, reject)=> {
			$http.delete('${FBCreds.URL}/video/${videoId}.json')
			.then((obj)=> {
				resolve(obj);
			})
			.catch((error)=> {
				console.log("error",error );
			})
		});
	};

	return { updateSingleVideo, getAllSavedVideos, saveVideo, deleteVideo, getSingleVideo};

});