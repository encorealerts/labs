$(function () {

  var activities = [], 
    LIMIT = 100, 
    NEW_REQUEST_THRESHOLD = (LIMIT / 10) * 2,
    blocked = false;
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
    }, []);

  function block() {
    $('#blocker').show();
    blocked = true;
  }

  function release() {
    $('#blocker').hide();
    blocked = false;
  }

  block();

  function requestActivities(polyArg) {
    var thisActivities, 
      callback = (typeof polyArg == 'function') ? polyArg : null, 
      async = (typeof polyArg == 'boolean') ? polyArg : true;
    if (!async) { block(); }
    $.ajax({
      type: "GET",
      url: '/alerts', 
      data: {limit: LIMIT}, 
      async: async,
      success: function (response) {
        if (!async) {
          thisActivities = response.activities;
        } else if (callback) {
          callback(response.activities);
        }
      }
    });
    if (!async) { release(); }
    return thisActivities;
  }

  function getActivity() {

    if (activities.length === 0) {
      activities = activities.concat(requestActivities(false));
    }

    if (activities.length <= NEW_REQUEST_THRESHOLD){
      requestActivities(function (_activities) {
        activities = activities.concat(_activities);
      });
    }
    return activities.splice(0,1)[0];
  }

  function embedActivity() {
    var activity = getActivity();
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

    $('#tweet-placeholder').empty().append(frame).attr('data-native-id', activity.native_id).addClass('loading');
  }

  function postAction(action) {
    block();
    $.ajax({
      type: 'POST',
      url: '/save',
      data: {
        nativeId: $('#tweet-placeholder').attr('data-native-id'),
        action: action
      },
      success: function (){
        release();
      }
    });
  }

  /* bindings */
  $('#next').on('click', embedActivity);

  $('[data-action]').on('click', function () {
    var action = $(this).attr('data-action');
    if (possibleActions.indexOf(action) > -1) {
      postAction(action);
      embedActivity();
    }
  });

  $(document).on('keydown', function (e) {
    var code = e.which ? e.which : e.keyCode;
    if (blocked || possibleKeys.indexOf(code) === -1) {
      return;
    }
    e.preventDefault();
    switch (code) {
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
      $('#tweet-placeholder').removeClass('loading');
    }
  });
});