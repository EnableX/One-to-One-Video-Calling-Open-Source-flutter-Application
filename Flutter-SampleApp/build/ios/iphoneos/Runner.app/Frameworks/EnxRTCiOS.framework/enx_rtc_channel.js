 var myRoom;
var fileUploadDataValue;
var selectedfiles;
var downloadedFile;
var downloadFailed;
var cancleResponse;
function passToken(token,fileObject) {
        EnxRtc.Logger.info(token);
        myRoom = EnxRtc.EnxRoom({"token":token});
        myRoom.setFsEndPoint(fileObject);
        window.location = 'iosWebViewLoaded:';
        myRoom.addEventListener("fs-upload-result", function(event) {
                const evtMsg = event.message;
                switch (evtMsg.messageType) {
                    case "upload-started":
                        selectedfiles = JSON.stringify(evtMsg.response);
                        window.location = 'iosFileUploadStart:';
                            break;
                    case "upload-completed":
                            fileUploadDataValue = JSON.stringify(evtMsg.response);
                            window.location = 'iosFileUploadFinished:';
                                break;
                    case "upload-failed":
                            fileUploadDataValue = JSON.stringify(evtMsg.response);
                            window.location = 'iosFileUploadFailed:';
                                break;
                     default:
                    }
        });
        myRoom.addEventListener("fs-download-result", function(event) {
                    const evtMsg = event.message;
                    switch (evtMsg.messageType) {
                        case "download-started":
                            downloadedFile = JSON.stringify(evtMsg.response);
                            window.location = 'iosFileDownloadStarted:';
                    break;
                  case "download-completed":
                        //alert("download-completed");
                    break;
                  case "download-failed":
                        downloadFailed = JSON.stringify(evtMsg.response);
                        window.location = 'iosFileDownoadFailed:';
                    break;
                  default:
                }
              });
                   myTestFtMobile = () => {
                       var x = document.createElement("INPUT");
                       x.setAttribute("type", "file");
                       x.setAttribute("id", 'files');
                       var elToAppend = document.body;
                       elToAppend.appendChild(x);
                       function handleFileSelect(evt) {
                           var files = evt.target.files;
                           if(files.length > 1){
                               window.location = 'iosMultipleFileError:';
                           }
                           else if(files[0].size === 0){
                              window.location = 'iosCorruptedFileError:';
                           }
                           else{
                               myRoom.filesToUpload = files;
                               sendFilesToMobile();
                           }
                       }
                document.getElementById('files').addEventListener('change', handleFileSelect, false);
                   }
             myTestFtMobile();
            EnxRtc.Logger.info(myRoom);
        }
    function fileSelectionDone(){
        return selectedfiles;
    }
     function sendFilesToMobile(){
         var callback =(res)=> {
            };
         console.log('files to upload are' + 'IOS' + JSON.stringify(myRoom.filesToUpload));
         myRoom.sendFiles(myRoom.filesToUpload,options={"isMobile":true},callback);
        }
        function updateSendFiletoIOS(){
               return fileUploadDataValue;
        }
        function failedSendFiletoIOS(){
                return fileUploadDataValue;
        }
         function downloadFile(data,index){
            EnxRtc.Logger.info(' file to download' + JSON.stringify(data),index);
            myRoom.mobileSetAvailableFile(data, function callback(res)
            {
             myRoom.recvFiles(index,options={"isMobile":true}, function callback(res){
                    if(res.result==0){
                    var reader = new window.FileReader();
                        reader.readAsDataURL(res.response.blob);
                        reader.onloadend = function() {
                        downloadedFile = reader.result;
                        window.location = 'iosFileDownoad:';
                    }
                }
                else{
                        downloadFailed = JSON.stringify(res)
                         window.location = 'iosFileDownoadFailed:';
                    }
            });
            }
            );
         }
    function fileDownloadedInitiatedIOS(){
        return downloadedFile;
    }
    function fileDownloadedIOS(){
        return downloadedFile;
    }
    function fileDownloadFailedIOS(){
        return downloadFailed;
    }
     function cancelUploads(cancelAll,id) {
       if(cancelAll){
           myRoom.cancelUploads(true,"cancel", function callback(res) {
                alert("All file cancle");
           cancleResponse = JSON.stringify(res);
            window.location = 'iosFileUploadCancle:';
       });
       }
       else{
        myRoom.cancelUploads(false, id, function callback(res) {
                cancleResponse = JSON.stringify(res);
                window.location = 'iosFileUploadCancle:';
            });
        }
     }
     function cancelDownloads(cancelAll, id) {
        if(cancelAll){
                myRoom.cancelDownloads(true,"cancel", function callback(res) {
                cancleResponse = JSON.stringify(res);
                window.location = 'iosFileDownloadCancle:';
                });
            }
        else{
                myRoom.cancelDownloads(false, id, function callback(res) {
                cancleResponse = JSON.stringify(res);
                window.location = 'iosFileDownloadCancle:';
                });
            }
     }
    function uploadCancleIOS(){
        return cancleResponse;
    }
    function DownloadCancleIOS(){
        return cancleResponse;
    }
