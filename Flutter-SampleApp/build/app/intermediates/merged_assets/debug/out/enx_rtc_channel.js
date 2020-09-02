            var myRoom;
            function passToken(token, fileObject) {
              EnxRtc.Logger.info(token);
              myRoom = EnxRtc.EnxRoom({ token: token });
              myRoom.setFsEndPoint(fileObject);

              myRoom.addEventListener("fs-upload-result", function(event) {
               // console.log(" file upload result ", JSON.stringify(event.message));
                const evtMsg = event.message;
                switch (evtMsg.messageType) {
                  case "upload-started":
               //     console.log(" fupload event upload-started ",evtMsg.response.upJobId," response",JSON.stringify(evtMsg.response));
                    Android.uploadStart(JSON.stringify(evtMsg.response));
                    break;
                  case "upload-completed":
              //     console.log(" fupload event upload-completed ",evtMsg.response.upJobId," response",JSON.stringify(evtMsg.response));
                    Android.sendFilesToMobile(JSON.stringify(evtMsg.response));
                    break;
                  case "upload-failed":
             //     console.log(" fupload event upload-failed ",evtMsg.response.upJobId," response",JSON.stringify(evtMsg.response));
                    Android.uploadFailed(JSON.stringify(evtMsg.response));
                    break;
                  default:
           //         console.log("default case file upload", evtMsg);
                }
              });
              myRoom.addEventListener("fs-download-result", function(event) {
            //    console.log(" file download result ", JSON.stringify(event.message));
                const evtMsg = event.message;
                switch (evtMsg.messageType) {
                  case "download-started":
          //      console.log("file download-started",evtMsg.response.jobId," response",JSON.stringify(evtMsg.response));
                      Android.downloadStarted(JSON.stringify(evtMsg.response));
                    break;
                  case "download-completed":
         //         console.log("file download-completed",evtMsg.response.jobId," response",JSON.stringify(evtMsg.response));
             //         Android.downloadCompleted(JSON.stringify(evtMsg.response));
                    break;
                  case "download-failed":
        //              console.log("file download-failed",evtMsg.response.jobId," response",JSON.stringify(evtMsg.response));
                      Android.downloadFailed(JSON.stringify(evtMsg.response),evtMsg.response.jobId);
                    break;
                  default:
                //    console.log("default case file download", evtMsg);
                }
              });

              myTestFtMobile = () => {
                var x = document.createElement("INPUT");
                x.setAttribute("type", "file");
                x.setAttribute("id", "files");
                var elToAppend = document.body;
                elToAppend.appendChild(x);

                function handleFileSelect(evt) {
                  var files = evt.target.files;

                  myRoom.filesToUpload = files;
                  if (files[0].size === 0) {
                    var res = {
                      result: 5100,
                      msg: "Upload Error: Corrupted File"
                    };
                    Android.uploadStart(JSON.stringify(res));
                  } else {
                    sendFilesToMobile();
                  }

                  //              var sFile = {
                  //                lastModified: files[0].lastModified,
                  //                lastModifiedDate: files[0].lastModifiedDate,
                  //                name: files[0].name,
                  //                size: files[0].size,
                  //                type: files[0].type
                  //              };
                  //              console.log("sFileEnx_rtc_channel", sFile.name);
                  //  Android.uploadStart(JSON.stringify(sFile));
                  //              for (var i = 0, f; (f = files[i]); i++) {
                  //                console.log("testFTMobile iterating file list", JSON.stringify(f));
                  //              }
                  //  sendFilesToMobile();
                }
                document
                  .getElementById("files")
                  .addEventListener("change", handleFileSelect, false);
              };
              myTestFtMobile();
              EnxRtc.Logger.info(myRoom);
              if (typeof Android !== "undefined" && Android !== null) {
                Android.passToken(token);
              } else {
                alert("Not viewing in webview");
              }
            }

            function sendFilesToMobile() {
              var callback = res => {
            //    console.log("send file response ", JSON.stringify(res));
              };
              EnxRtc.Logger.info(
                " files to upload are",
                JSON.stringify(myRoom.filesToUpload)
              );
              myRoom.sendFiles(
                myRoom.filesToUpload,
                (options = { isMobile: true }),
                callback
              );
            }

            function downloadFile(data,index) {
              EnxRtc.Logger.info(" file to download", JSON.stringify(data),index);
              myRoom.mobileSetAvailableFile(data, function callback(res) {
             //   console.log("responsemobileSetAvailableFile", JSON.stringify(res));
                myRoom.recvFiles(index, (options = { isMobile: true }), function callback(res) {
           //       console.log("responserecvFiles", JSON.stringify(res));
                  if (res.result == 0) {
                    var reader = new window.FileReader();
                    reader.readAsDataURL(res.response.blob);
                    reader.onloadend = function() {
                      var base64data = reader.result;
                      Android.getBase64String(base64data,index);
                    };
                  } else {

                    Android.downloadFailed(JSON.stringify(res),index);
                  }
                });
              });
            }

            function cancelUploads(cancelAll, id) {
        //      console.log("cancelUploads", id, cancelAll);
              if(cancelAll){
              myRoom.cancelUploads(true,"cancel", function callback(res) {
              Android.uploadCancelled(JSON.stringify(res),id);
         //     console.log("cancel upload true", JSON.stringify(res));
              });
              }
              else{
               myRoom.cancelUploads(false, id, function callback(res) {
               Android.uploadCancelled(JSON.stringify(res),id);
            //   console.log("cancel upload", JSON.stringify(res));
                            });
              }

            }

            function cancelDownloads(cancelAll, id) {
       //     console.log("cancelDownloads", id, cancelAll);
                          if(cancelAll){
                          myRoom.cancelDownloads(true,"cancel", function callback(res) {
                          Android.downloadCancelled(JSON.stringify(res),id);
                    //      console.log("cancel download true", JSON.stringify(res));
                          });
                          }
                          else{
                           myRoom.cancelDownloads(false, id, function callback(res) {
                           Android.downloadCancelled(JSON.stringify(res),id);
                      //     console.log("cancel download", JSON.stringify(res));
                                        });
                          }
            }
