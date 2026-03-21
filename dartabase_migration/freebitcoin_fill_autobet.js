// ==UserScript==
// @name         New Userscript
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  try to take over the world!
// @author       You
// @match        https://freebitco.in/?op=home
// @grant        none
// ==/UserScript==


(function () {
    'use strict';


    // Your code here...

    document.querySelector('#free_play_tab').style.display = "none";
    if (window.self == window.top) {
        addFrames(10);

        //add do call button
        var div = document.createElement("div");
        div.style.cssText = "width:50px;height:50px;position:fixed;left:100px;top:200px;border:1px solid black;";
        div.innerHTML = "start Bet";
        div.onclick = function a() {
            doCall();
        };
        var body = document.querySelector("body");
        body.appendChild(div);

        //add add frames button
        var div2 = document.createElement("div");
        div2.style.cssText = "width:50px;height:50px;position:fixed;left:100px;top:300px;border:1px solid black;";
        div2.innerHTML = "add 10 frames";
        div2.onclick = function b() {
            addFrames(10);
        };

        body.appendChild(div2);
    } else {

        doCall();
        removeAndMoveTo();
        //document.querySelector('#double_your_btc_tab').style.display = "none";
    }


})();


function doCall() {
    document.querySelector(".double_your_btc_link").click();
    document.querySelector("#auto_bet_on").click();
    document.querySelector("#autobet_base_bet").value = "0.00000001";
    document.querySelector("#autobet_roll_count").value = "1000000";
    document.querySelector("#autobet_bet_hi").checked = true;
    document.querySelector("#autobet_bet_lo").checked = false;
    document.querySelector("#autobet_bet_alternate").checked = false;
    document.querySelector("#stop_after_profit").checked = true;
    document.querySelector("#stop_after_profit_value").value = "1";
    document.querySelector("#autobet_lose_return_to_base").checked = false;
    document.querySelector("#autobet_lose_increase_bet").checked = true;
    document.querySelector("#autobet_lose_increase_bet_percent").value = "100";
    document.querySelector("#autobet_change_client_seed").checked = true;
    document.querySelector("#autobet_dnr").checked = true;
    document.querySelector("#start_autobet").click();
}

function addFrames(iMax) {
    for (var i = 0; i < iMax; i++) {
        addFrame();
    }
}

function removeAndMoveTo() {
    setTimeout(function () {
        note = document.querySelector('#autobet_pl');
        document.querySelector('h1.counter').style.display = "none";
        document.querySelector('div#double_your_btc_result').style.display = "none";

        //document.querySelector('#double_your_btc_middle_section').style.display = "none";
        document.querySelector('#bet_history_table_rows').style.display = "none";
        screenPosition = note.getBoundingClientRect();
        window.scrollTo(1, screenPosition.top - 100);

    }, 2000);
}
function addFrame() {
    var ifrm = document.createElement("iframe");
    ifrm.setAttribute("src", "https://freebitco.in/?op=home");
    ifrm.style.width = (document.body.clientWidth / 4) - 10 + "px";
    ifrm.id = "id" + i;
    ifrm.style.height = "200px";

    document.body.appendChild(ifrm);
}





