
$(function () {

  Blocker.block();

  var 
    LIMIT = 100, 
    Actions = {
      BUSINESS: 'business',
      BOT: 'bot',
      PERSONAL: 'personal',
      SPAM: 'spam'
    },
    possibleActions = Object.keys(Actions).map(function (k) {return Actions[k]}),
    Keys = {
      LEFT: 37,
      UP: 38,
      RIGHT: 39,
      BOTTOM: 40,
      S: [115, 83]
    },
    possibleKeys = Object.keys(Keys).map(function (k) {return Keys[k] }).reduce(function(a, b) {
      return a.concat ? a.concat(b) : b;
    }, []),
    $trainedCount = $('#header-status .status-value'),
    $placeholder = $('#placeholder');

  $('#header-status').show();

  function embedActivity() {
    var activity = Requester.getActivity('twitter', LIMIT);
    var frame = $('<iframe></iframe>').attr({
      src: 'http://twitframe.com/show?url=' + encodeURIComponent(activity.link.replace('https://','http://')),
      width: 500,
      height: 300,
      frameBorder: 0,
      seamless: true,
      style: 'opacity:0',
      id: 'tweet_' + activity.native_id
    });

    frame.on('load', function(e) {
      this.contentWindow.postMessage({ element: this.id, query: "height" }, "http://twitframe.com");
    });

    $placeholder.empty().append(frame).attr('data-native-id', activity.native_id).addClass('loading');
  }

  function postAction(action) {
    Requester.postAction($placeholder.attr('data-native-id'), 'twitter', action, function (data) {
      if (data && data.count) {
        $trainedCount.text(data.count);
      }
    });
  }

  /* bindings */
  $('[data-action]').on('click', function () {
    var action = $(this).attr('data-action');
    if (possibleActions.indexOf(action) > -1) {
      postAction(action);
      embedActivity();
    }
  });

  $(document).on('keydown', function (e) {
    var code = e.which ? e.which : e.keyCode;
    if (Blocker.blocked || possibleKeys.indexOf(code) === -1) {
      return;
    }
    e.preventDefault();
    switch (code) {
      case Keys.RIGHT: embedActivity(); break;
      case Keys.LEFT: postAction(Actions.PERSONAL); break;
      case Keys.UP: postAction(Actions.BUSINESS); break;
      case Keys.BOTTOM: postAction(Actions.BOT); break;
      case Keys.S[0]: 
      case Keys.S[1]: postAction(Actions.SPAM); break;
    }
    embedActivity();
  });

  embedActivity();

  /* listen for the return message once the tweet has been loaded */
  $(window).bind("message", function(e) {
    var oe = e.originalEvent;
    if (oe.origin != "http://twitframe.com" && oe.origin != "https://twitframe.com") {
      return;
    }
    
    if (oe.data.height && oe.data.element.match(/^tweet_/)) {
      $("#" + oe.data.element).css({height: (parseInt(oe.data.height) + 12) + "px", opacity: 1})
      $placeholder.removeClass('loading');
    }
  });
});