# TODO

- on getting whitelisted, user receives X amount of ERC20 token.
- spend on creating new posts
- earn more tokens by engaging with other's posts (like, comment, vote, on following certain number of people

  - like get 10 token once you follow 100 people)

- event for each functions with indexed (both the contracts)

# FLOW

- Get whitelisted
- add catagory (pass string as an argument) (if none exist)
- see the list of the catagory
- get catagory id
- add post (string content catagory id)
- checkCoolDownTime (you can see your cooldown time only)
- get list of posts
- select post (and get its creator's address && content id)
- getPostId (creator's address && the content id you copied)
- up/down vote post (pass postId as an argument)
- tip any creator directly
- can read original post via getOriginalContent
