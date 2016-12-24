"use strict";
app.factory("AuthFactory", function($window, $http, FBCreds) {
    let currentUser = null;
    let createUser = (userObj) => {
        console.log("userObj", userObj);
        return firebase.auth().createUserWithEmailAndPassword(userObj.email, userObj.password);
    };
    let loginUser = (userObj) => {
        return firebase.auth().signInWithEmailAndPassword(userObj.email, userObj.password);
    };
    let logoutUser = () => {
        return firebase.auth().signOut();
    };
    let isAuthenticated = () => {
        return new Promise((resolve, reject) => {
            firebase.auth().onAuthStateChanged((user) => {
                if (user) {
                    currentUser = user.uid;
                    console.log("currentUser", currentUser);
                    resolve(true);
                } else {
                    resolve(false);
                }
            });
        });
    };

    let getUser = () => {

        return currentUser;
    };

    let saveUserToFB = (userObj)=>{
        return new Promise ((resolve, reject)=>{
            $http.post(`${FBCreds.URL}/users.json`, angular.toJson(userObj))
            .then((userInfo)=> {
                resolve(userInfo);
                console.log("userInfo from saveUserToFB", userInfo);
            })
            .catch((error)=> {
                console.log("error from saveUserToFB" );
            })
        })

    };
  
    
     let getAllUsers = ()=> {
        let allUsers = [];
        return new Promise((resolve, reject)=> {

            $http.get(`${FBCreds.URL}/users.json`)
            .then((users)=>{
                let usersArray = users.data;
                Object.keys(usersArray).forEach((key)=>{
                    usersArray[key].id = key;
                    allUsers.push(usersArray[key]);
                })
                console.log("users from getAllUsers",allUsers );
                resolve(allUsers);
            })

            .catch((error)=> {
                console.log("error getting all users");
            });
        });
    };
      



    return { createUser, loginUser, logoutUser, isAuthenticated, getUser,  saveUserToFB, getAllUsers  }

});