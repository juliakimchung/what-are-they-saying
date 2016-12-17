"use strict";
app.factory("AuthFactory", function() {
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

    return { createUser, loginUser, logoutUser, isAuthenticated, getUser };

});
