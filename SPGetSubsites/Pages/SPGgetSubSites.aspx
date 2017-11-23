﻿<%@ Page language="C#" Inherits="Microsoft.SharePoint.WebPartPages.WebPartPage, Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>

<WebPartPages:AllowFraming ID="AllowFraming" runat="server" />

<html>
<head>
    <title></title>

    <script type="text/javascript" src="../Scripts/jquery-1.9.1.min.js"></script>
    <script type="text/javascript" src="/_layouts/15/MicrosoftAjax.js"></script>
    <script type="text/javascript" src="/_layouts/15/sp.runtime.js"></script>
    <script type="text/javascript" src="/_layouts/15/sp.js"></script>
    <script src="../Scripts/jquery.easyPaginate.js"></script>
    <%--<link href="../Content/jquery.snippet.min.css" rel="stylesheet" />--%>
    <link href="../Content/App.css" rel="stylesheet" />
    <script type="text/javascript">
        // Set the style of the client web part page to be consistent with the host web.
        (function () {
            'use strict';

            var hostUrl = '';
            var link = document.createElement('link');
            link.setAttribute('rel', 'stylesheet');
            if (document.URL.indexOf('?') != -1) {
                var params = document.URL.split('?')[1].split('&');
                for (var i = 0; i < params.length; i++) {
                    var p = decodeURIComponent(params[i]);
                    if (/^SPHostUrl=/i.test(p)) {
                        hostUrl = p.split('=')[1];
                        link.setAttribute('href', hostUrl + '/_layouts/15/defaultcss.ashx');
                        break;
                    }
                }
            }
            if (hostUrl == '') {
                link.setAttribute('href', '/_layouts/15/1033/styles/themable/corev15.css');
            }
            document.head.appendChild(link);
        })();
    </script>

    <script type="text/javascript">

        var hostweburl;
        var appweburl;

        // Load the required SharePoint libraries
        $(document).ready(function () {
            //Get the URI decoded URLs.
            hostweburl = decodeURIComponent(getQueryStringParameter("SPHostUrl"));
            appweburl = decodeURIComponent(getQueryStringParameter("SPAppWebUrl"));

            // resources are in URLs in the form: web_url/_layouts/15/resource
            var scriptbase = hostweburl + "/_layouts/15/";

            // Load the js files and continue to the successHandler
            $.getScript(scriptbase + "SP.RequestExecutor.js", execCrossDomainRequest);

        });

        // Function to prepare and issue the request to get SharePoint data
        function execCrossDomainRequest() {
            // executor: The RequestExecutor object Initialize the RequestExecutor with the app web URL.
            var executor = new SP.RequestExecutor(appweburl);

            // Deals with the issue the call against the app web.
            executor.executeAsync({
                url: appweburl + "/_api/SP.AppContextSite(@target)/web/webs?@target='" + hostweburl + "'",
                method: "GET",
                headers: { "Accept": "application/json; odata=verbose" },
                success: successHandler,
                error: errorHandler
            }
            );
        }

        // Function to handle the success event. Prints the data to the page.
        function successHandler(data) {
            var jsonObject = JSON.parse(data.body);
            var items = [];
            var results = jsonObject.d.results;


            $(results).each(function () {
                items.push('<li class="element">'
                    + '<a target="_parent" href="' + this.Url + '">' + this.Title + '</a>'
                    + '</li>');
            });

            $("#lisSiteContainer ul").html(items.join(''));

            var hideElement = $('#lisSiteContainer ul li a:contains("SPGetSubsites")');
            $(hideElement).css('display', 'none');

            $('#easyPaginate').easyPaginate({
                paginateElement: 'li',
                elementsPerPage: 3,
                effect: 'climb'
            });
        }


        // Function to handle the error event. Prints the error message to the page.
        function errorHandler(data, errorCode, errorMessage) {
            console.log("Error, " + errorCode + ', ' + errorMessage + ', ' + data);
        }

        // Function to retrieve a query string value.
        function getQueryStringParameter(paramToRetrieve) {
            var params =
                document.URL.split("?")[1].split("&");
            var strParams = "";
            for (var i = 0; i < params.length; i = i + 1) {
                var singleParam = params[i].split("=");
                if (singleParam[0] == paramToRetrieve)
                    return singleParam[1];
            }
        }
    </script>
</head>
<body>
    <div id="lisSiteContainer">
        <ul id="easyPaginate">

        </ul>
    </div>
</body>
</html>
