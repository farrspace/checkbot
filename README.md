# Checkbot
## A helpful robot to check your commits and make sure you don't look silly.


Here's a sample

```
[~/dev/master] <@master> $ ruby ~/checkbot.rb

  _._          _____
 [O+O]        |   //|
 < X >        |\\// |
 _/ \_  _[]___|_\/__|___[]_[]_[]_

Checkbot is checking staged changes...

! You staged a '.css' file without staging a '.less' file.   Did you mean to do
  that?   (CSS files should not be edited directly, LESS files should be edited,
  then compiled into CSS, with both being checked in.)

! You staged a '.en.yml' file without staging 'defaults.js'.
  Did you mean to do that?
  (When updating translations, defaults.js should be regenerated.)

! You staged 'new.js.erb', which contains 'debugger'.
  Did you mean to do that?

1-function foobar(){
2-  alert("whoops");
3:  debugger;
4-
5-}

! You staged 'new.js.erb', which contains 'alert'.
  Did you mean to do that?

1-function foobar(){
2:  alert("whoops");
3-  debugger;
4-
5-}

~ You staged files in 'public/stylesheets', you should consider checking your
  changes across supported browsers, like IE.

[~/dev/master] <@master> $

```

