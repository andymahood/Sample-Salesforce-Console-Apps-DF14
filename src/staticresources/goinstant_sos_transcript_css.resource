* {
    box-sizing: border-box;
    -moz-box-sizing: border-box;        
}
html {
    height: 100%;
}
body {
    position: relative;
    height: 100%;
    margin: 0;
    padding: 12px;
    overflow: hidden;
    background: #2a94d6;
    font-family: sans-serif;
}
.bPageBlock,
.apexp,
.pbBody {
    height: 100%;
}

.container {
    position: relative;
    padding: 12px;
    max-width: 500px;
    margin: auto;
    background: #f0f1f2;
    border: 1px solid #0f6ca6;
    box-shadow: 0 2px 3px rgba(0,0,0,.2);
    border-radius: 4px;
    height: 70%;
}

.icon {
    position: relative;
    display: inline-block;
    width: 24px;
    height: 21px;
    margin-right: .3em;
}

.icon-sf1-logo {
    background-position: 0 -31px !important;
    width: 90px;
    height: 74px;
    position: absolute;
    bottom: 12px;
    left: 50%;
    margin-left: -45px;
}

.icon-sos {
    top: 8px;
    width: 34px;
    height: 30px;
    background-position: 0 0;
}

.icon-transcript {
    background-position: -40px 0 !important;
}

.icon-case {
    background-position: -69px 0 !important;
}

.icon-time {
    background-position: -96px 0 !important;
}

h2 {
    margin: .25em 0 .5em;
    text-align: center;
    color: white;
    font-size: 20px;
    line-height: 2;
    -webkit-font-smoothing: antialiased;
}

.status > div {
    padding: 12px 2px;
    border-bottom: 1px solid #ddd;
    font-size: .9em;
}
    .status > div:first-child {
        padding-top: 6px;
    }

    .status > div span {
        font-weight: bold;
    }

    .status > div span.icon {
        margin-bottom: -4px;
    }

.attached-to-case span {
    color: #d98c00;
}

.session-duration span {
    color: #6352bf;
}

.return {
    position: absolute;
    width: 100%;
    bottom: 0;
    left: 0;
    padding: 12px;
}
.button {
    display: block;
    border: 1px solid #c3cbce;
    padding: 12px 2px;
    text-align: center;
    border-radius: 4px;
    color: #222;
    font-size: .9em;
    text-decoration: none;
    background: rgb(255,255,255); /* Old browsers */
    background: -moz-linear-gradient(top,  rgba(255,255,255,1) 0%, rgba(233,233,233,1) 100%); /* FF3.6+ */
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(255,255,255,1)), color-stop(100%,rgba(233,233,233,1))); /* Chrome,Safari4+ */
    background: -webkit-linear-gradient(top,  rgba(255,255,255,1) 0%,rgba(233,233,233,1) 100%); /* Chrome10+,Safari5.1+ */
    background: -o-linear-gradient(top,  rgba(255,255,255,1) 0%,rgba(233,233,233,1) 100%); /* Opera 11.10+ */
    background: -ms-linear-gradient(top,  rgba(255,255,255,1) 0%,rgba(233,233,233,1) 100%); /* IE10+ */
    background: linear-gradient(to bottom,  rgba(255,255,255,1) 0%,rgba(233,233,233,1) 100%); /* W3C */
}
    .button:hover {
        color: #00588f;
    
    }

    .button:active {
        background: -moz-linear-gradient(top,  rgba(233,233,233,1) 0%, rgba(255,255,255,1) 100%); /* FF3.6+ */
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(233,233,233,1)), color-stop(100%,rgba(255,255,255,1))); /* Chrome,Safari4+ */
        background: -webkit-linear-gradient(top,  rgba(233,233,233,1) 0%,rgba(255,255,255,1) 100%); /* Chrome10+,Safari5.1+ */
        background: -o-linear-gradient(top,  rgba(233,233,233,1) 0%,rgba(255,255,255,1) 100%); /* Opera 11.10+ */
        background: -ms-linear-gradient(top,  rgba(233,233,233,1) 0%,rgba(255,255,255,1) 100%); /* IE10+ */
        background: linear-gradient(to bottom,  rgba(233,233,233,1) 0%,rgba(255,255,255,1) 100%); /* W3C */
    }