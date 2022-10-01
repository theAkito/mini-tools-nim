## Retrieve Gamefound Project comments

### Build
```bash
cd generic/web/gamefoundprojectcomments
nimble install -d
nim c gamefoundprojectcomments.nim
```

#### Provide Gamefound link to a project
```bash
./gamefoundprojectcomments 'https://gamefound.com/projects/boardcubator/kcdboardgame' "jsonSingle" # Output single JSON object with an array containing all comments.
./gamefoundprojectcomments 'https://gamefound.com/projects/boardcubator/kcdboardgame' "jsonStream" # Output a stream of JSON objects, one per line, each containing a batch of up to 10 comments.
```

### Output

#### OutputType: jsonSingle
```json
.....
  {
    "projectCommentID": 123123,
    "author": {
      "userID": 321321,
      "nickname": "Crazyusername82",
      "avatarUrl": "https://imgcdn.gamefound.com/userimagecomment/users/noimage.jpg"
    },
    "authorID": 23132132,
    "authorType": 0,
    "createdAt": "2022-09-20T18:02:53.317Z",
    "editedAt": null,
    "isDeleted": false,
    "isHidden": false,
    "likesCount": 3,
    "newRepliesCount": 0,
    "parentID": null,
    "pinnedAt": null,
    "projectID": 3131,
    "projectUpdateID": "",
    "text": "Nice game.", // Actual comment text.
    "userProjectComment": ""
  },
.....
```

#### OutputType: jsonStream
```json
.....
{"author":{"userID":123123,"nickname":"Babyboy85","avatarUrl":"https://imgcdn.gamefound.com/userimagecomment/users/noimage.jpg"},"authorID":23132132,"commentID":123123,"authorType":0,"createdAt":"2022-10-05T12:28:00.43Z","editedAt":null,"isDeleted":false,"isHidden":false,"likesCount":0,"newRepliesCount":0,"parentID":null,"pinnedAt":null,"text":"Clowns","children":[],"childrenTotalCount":0,"userComment":null}
{"author":{"userID":321321,"nickname":"Babygirl69","avatarUrl":"https://imgcdn.gamefound.com/userimagecomment/users/noimage.jpg"},"authorID":23132132,"commentID":123124,"authorType":0,"createdAt":"2022-10-04T03:07:12.35Z","editedAt":null,"isDeleted":false,"isHidden":false,"likesCount":0,"newRepliesCount":0,"parentID":null,"pinnedAt":null,"text":"Fools","children":[],"childrenTotalCount":0,"userComment":null}
.....
```