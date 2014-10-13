.sfdcBody.net-withGlobalHeader {
    margin: 0;
    background: #F7F7F7;
    }
    .header {
      padding: 10px 12px;
      border-bottom: 1px solid #ccc;
    }
    .header p {
      color: #555;
      margin-bottom: 0;
	  margin-top: 6px;
    }
	.header .left {
    	display: inline-block;
    	width: 70%;
	}
	.header .right {
    	position: absolute;
    	top: 10px;
    	right: 10px;
    	width: 80px;
    	text-align: right;
	}
	.header .header-button + .header-button {
    	margin-top: 5px;
	}
	.header .header-button .offline {
    	color: #ff0000;
	}
	.header .header-button .online {
    	color: #00ff00;
	}
	.header .statusButton {
		display: none;
		margin-top: 6px;
	}

    h1 {
        font-size: 15px;
        font-weight: bold;
        margin-bottom: 10px;
        margin-top: 10px;
    }

    #sos_queue {
        height: 622px;
        overflow-y: auto;
    	background: white;
    }
    .queue_item {
        font-size: 11px;
		padding: 12px; 
    }
    .queue_item + .queue_item {
        border-top: 1px dotted #ccc;
    }
	.queue_item .queue_main {
    	height: 29px;
	}
	.queue_item .queue_details {
    	margin-top: 5px;
    	font-size: 11px;
    	display: none;
    	color: #aaa;
    	line-height: 15px;
	}
	.queue_item .queue_details .label {
    	color: #888;
    	font-weight: bold;
	}
    .queue_item .timeago {
        float: left;
    	margin-top: 3px;
        margin-right: 10px;
    	color: #aaa;
    }
    .queue_item .customerEmail {
        width: 170px;
        text-overflow: ellipsis;
        overflow: hidden;
        font-size: 12px;
        font-weight: bold;
        color: #0071BD;
    }
    .queue_item_controls {
        float: right;
        margin-top: -11px;
    }
    .queue_item .cancel {
		font-size: 16px;
        color: #999;
        padding: 6px;
        margin-left: 6px;
        position: relative;
        top: 1px;
        right: -2px;
    	cursor: pointer;
    }
        .queue_item .cancel:hover {
            color: tomato;
    		text-decoration: none;
        }
    .queue_item.opening {
        color: #ccc;
    }
    .queue_item.opening .launch {
        background-color: #666;
    }
    .queue_item .launch:hover {
        background-color: #1f77a3;
    }
    a.clearAll {
        display: block;
        position: absolute;
        top: 7px;
        right: 6px;
    }
    .sos-button {
        display: inline-block;
      	cursor: pointer;
        border: 1px solid #c3cbce;
        padding: 3px 5px;
        text-align: center;
        border-radius: 3px;
        color: #222;
        font-size: .9em;
      	font-weight: 300;
        text-decoration: none;
      	box-shadow: 0 1px 0 #4F6879;
        background: rgb(255,255,255); /* Old browsers */
        background: -moz-linear-gradient(top,  rgba(255,255,255,1) 0%, rgba(233,233,233,1) 100%); /* FF3.6+ */
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(255,255,255,1)), color-stop(100%,rgba(233,233,233,1))); /* Chrome,Safari4+ */
        background: -webkit-linear-gradient(top,  rgba(255,255,255,1) 0%,rgba(233,233,233,1) 100%); /* Chrome10+,Safari5.1+ */
        background: -o-linear-gradient(top,  rgba(255,255,255,1) 0%,rgba(233,233,233,1) 100%); /* Opera 11.10+ */
        background: -ms-linear-gradient(top,  rgba(255,255,255,1) 0%,rgba(233,233,233,1) 100%); /* IE10+ */
        background: linear-gradient(to bottom,  rgba(255,255,255,1) 0%,rgba(233,233,233,1) 100%); /* W3C */
    }
        .sos-button:hover {
            color: #00588f;
        	text-decoration: none;
        }
    
        .sos-button:active {
          	box-shadow: 0 1px 0 #4F6879;
            background: -moz-linear-gradient(top,  rgba(233,233,233,1) 0%, rgba(255,255,255,1) 100%); /* FF3.6+ */
            background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(233,233,233,1)), color-stop(100%,rgba(255,255,255,1))); /* Chrome,Safari4+ */
            background: -webkit-linear-gradient(top,  rgba(233,233,233,1) 0%,rgba(255,255,255,1) 100%); /* Chrome10+,Safari5.1+ */
            background: -o-linear-gradient(top,  rgba(233,233,233,1) 0%,rgba(255,255,255,1) 100%); /* Opera 11.10+ */
            background: -ms-linear-gradient(top,  rgba(233,233,233,1) 0%,rgba(255,255,255,1) 100%); /* IE10+ */
            background: linear-gradient(to bottom,  rgba(233,233,233,1) 0%,rgba(255,255,255,1) 100%); /* W3C */
        }
        .sos-button.launch {
            padding: 5px 14px;
            font-size: 11px;
            font-weight: 400;
            text-transform: uppercase;
            border-color: #00788F;
            box-shadow: inset 0 0px 0 1px #2BB5CF;
            color: #FFF;
            background: rgb(22,160,205); /* Old browsers */
            background: -moz-linear-gradient(top,  rgba(22,160,205,1) 0%, rgba(13,144,188,1) 100%); /* FF3.6+ */
            background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(22,160,205,1)), color-stop(100%,rgba(13,144,188,1))); /* Chrome,Safari4+ */
            background: -webkit-linear-gradient(top,  rgba(22,160,205,1) 0%,rgba(13,144,188,1) 100%); /* Chrome10+,Safari5.1+ */
            background: -o-linear-gradient(top,  rgba(22,160,205,1) 0%,rgba(13,144,188,1) 100%); /* Opera 11.10+ */
            background: -ms-linear-gradient(top,  rgba(22,160,205,1) 0%,rgba(13,144,188,1) 100%); /* IE10+ */
            background: linear-gradient(to bottom,  rgba(22,160,205,1) 0%,rgba(13,144,188,1) 100%); /* W3C */
        }
            .sos-button.launch:hover {
                background: rgb(69,172,204); /* Old browsers */
                background: -moz-linear-gradient(top,  rgba(69,172,204,1) 0%, rgba(52,152,186,1) 100%); /* FF3.6+ */
                background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(69,172,204,1)), color-stop(100%,rgba(52,152,186,1))); /* Chrome,Safari4+ */
                background: -webkit-linear-gradient(top,  rgba(69,172,204,1) 0%,rgba(52,152,186,1) 100%); /* Chrome10+,Safari5.1+ */
                background: -o-linear-gradient(top,  rgba(69,172,204,1) 0%,rgba(52,152,186,1) 100%); /* Opera 11.10+ */
                background: -ms-linear-gradient(top,  rgba(69,172,204,1) 0%,rgba(52,152,186,1) 100%); /* IE10+ */
                background: linear-gradient(to bottom,  rgba(69,172,204,1) 0%,rgba(52,152,186,1) 100%); /* W3C */
            }
			.sos-button.launch:active {
                background: rgb(52,152,186); /* Old browsers */
                background: -moz-linear-gradient(top,  rgba(52,152,186,1) 0%, rgba(69,172,204,1) 100%); /* FF3.6+ */
                background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(52,152,186,1)), color-stop(100%,rgba(69,172,204,1))); /* Chrome,Safari4+ */
                background: -webkit-linear-gradient(top,  rgba(52,152,186,1) 0%,rgba(69,172,204,1) 100%); /* Chrome10+,Safari5.1+ */
                background: -o-linear-gradient(top,  rgba(52,152,186,1) 0%,rgba(69,172,204,1) 100%); /* Opera 11.10+ */
                background: -ms-linear-gradient(top,  rgba(52,152,186,1) 0%,rgba(69,172,204,1) 100%); /* IE10+ */
                background: linear-gradient(to bottom,  rgba(52,152,186,1) 0%,rgba(69,172,204,1) 100%); /* W3C */
            }
            
.overlayContents .buttons {
    float: right;
}

.overlayContents .cancel {
    cursor: pointer;
    margin-right: 8px;
    color: #999;
}

.overlayBg {
        position: fixed;
        width: 100%;
        height: 100%;
        background-color: #000;
        opacity: 0.4;
        display: none;
        z-index: 100;
    }
    .overlayContents {
        position: absolute;
        margin-left: 15px;
        padding: 15px;
        top: 100px;
        width: 258px;
        background-color: #FFF;
        z-index: 110;
        display: none;
        border-radius: 3px;
        box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.25);
    }
    .overlayContents .msg {
    	display: block;
        color: #222;
        font-size: 12px;
    	margin-bottom: 10px;
    }