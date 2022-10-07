import json

type
  OutputType* = enum
    jsonSingle,
    jsonStream
  CommentRequest* = object
    commentThreadID*: int
    freshCommentID*: JsonNode # int
    lastFetchedCommentID*: JsonNode # int
    lastPinnedAt*: JsonNode # string
    lastScore*: int
    sortType*: int # 0
    tag*: JsonNode
  CommentResponseAuthor* = object
    userID*: int
    nickname*: string
    avatarUrl*: string
  CommentResponseUserComment* = object
    commentID*: int
    userCommentID*: int
    likedAt*: JsonNode # Date
    followedAt*: JsonNode # Date
    pinnedAt*: JsonNode # Date
  CommentResponseItem* = object
    author: CommentResponseAuthor
    authorID*: int
    commentID*: int
    authorType*: int
    createdAt*: string # Date
    editedAt*: JsonNode # Date
    isDeleted*: bool
    isHidden*: bool
    likesCount*: JsonNode
    newRepliesCount*: JsonNode
    parentID*: JsonNode
    pinnedAt*: JsonNode # Date
    text*: string
    children*: JsonNode # seq[CommentResponseItem]
    childrenTotalCount*: int
    userComment*: JsonNode # CommentResponseUserComment
  CommentResponse* = object
    pagedItems*: seq[CommentResponseItem]
    totalItemCount*: int

func toOutputType*(enumAsString: string): OutputType =
  case enumAsString:
    of $jsonSingle: jsonSingle
    else: jsonStream