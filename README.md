# Yangtze

A low-level CMS built on top of a MastoAPI-compatible server (such as Mastodon, Pleroma or [Pothole](https://github.com/penguinite/pothole.git))

PS: *I made this thing entirely for myself, so, some things are poorly documented and you probably shouldn't use this as a real CMS. Open a bug report if you really want me to fix this mess so you can use this as well, just know that I might be busy with more important things.*

This source tree has no theme and it is expected that you will configure it on your own. For my own personal sites and whatnot, I use a different branch which has my custom theme.

## Why?

I'll admit, using this on top of a heavyweight Mastodon instance makes no sense... And is definitely a bad idea.
But the general idea is to host a [GoToSocial](https://gotosocial.org/) instance (or [Pothole](https://github.com/penguinite/pothole.git) in the future)
and then to host Yangtze on top of it to provide a CMS platform!

## But why?

The primary point is working federation, if we use a server that was already designed with ActivityPub in mind then we don't need to monkey-patch ActivityPub onto our CMS!
We will be able to federate posts and natively support comments through the fediverse! This is all exciting stuff, even if it does mean spambots are 10x worse now.
But you could also just disable federation in whatever server you're using, that will also end all support for comments.

The second point is easy multi-user and post support! Yangtze just displays all local posts as blog articles or microblog posts (if you're interested in that)
Yangtze *does* lack a bit of control over how exactly the post will be formatted and stored, all those messy details will have to be handled by your server of choice.
So, fx. you might not be able to choose the exact URL your post will be visible on, if that is a deal-breaker to you then you need to use a real CMS, not this thing.

Yangtze is just a frontend (or, Mastodon client) that also supports rendering about pages and other simple things.

## How does it work?

Yangtze does not have login pages, nor does it have sign up pages. You can't write a post through Yangtze.

When you have the entire setup ready (Yangtze + Your backend of choice),
you'll need to log on to your server (using [whatever client](https://joinmastodon.org/apps), it doesn't matter) and then just make a regular post.
Yangtze will retrieve that post and then display it on your page! (You can also access it thru `[YOUR SITE HERE]/posts/[POST ID]`) 

To write simple pages, you'll need to make a folder named `pages` and then add your article in templated HTML. It will be available at `[YOUR SITE HERE]/[YOUR PAGE NAME]/`
So, if you wrote a document named `about.tmpl` then you should see it at `[YOUR SITE HERE]/about/`

You can configure Yangtze through a config file.

## Templating and more internal messy details

Files in the `pages/` folder are treated as "template files", so if you create a file at `pages/bio.tmpl` then it will be rendered and visible through `[YOUR SITE HERE]/bio/`.
Templates cn pull in data from the config file (and also the contents of other files!)

Files in the `static/` folder are just treated as plain simple static files, so, if you create a file at `static/hello.png` then it will be visible at `[YOUR SITE HERE]/hello.png`