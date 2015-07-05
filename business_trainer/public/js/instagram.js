
$(function () {

  Blocker.block();

  var 
    LIMIT = 100, 
    Actions = {
      HAM: 'ham',
      SPAM: 'spam'
    },
    possibleActions = Object.keys(Actions).map(function (k) {return Actions[k]}),
    Keys = {
      UP: 38,
      RIGHT: 39,
      BOTTOM: 40
    },
    possibleKeys = Object.keys(Keys).map(function (k) {return Keys[k] }).reduce(function(a, b) {
      return a.concat ? a.concat(b) : b;
    }, []),
    $trainedCount = $('#header-status .status-value'),
    $placeholder = $('#placeholder');

  $('#header-status').show();

  function embedActivity() {
    var activity = Requester.getActivity('instagram', LIMIT);
    var frame = $('<iframe></iframe>').attr({
      src: activity.link.replace('http://','https://') + 'embed',
      //src: 'https://instagram.com/p/4ushproS3T/embed',
      width: 500,
      height: 300,
      frameBorder: 0,
      seamless: true,
      style: 'opacity:0',
      id: 'post_' + activity.native_id
    });

    $placeholder.empty().append(frame).attr('data-native-id', activity.native_id).addClass('loading');
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

  function postAction(action) {
    Requester.postAction($placeholder.attr('data-native-id'), 'instagram', action, function (data) {
      if (data && data.count) {
        $trainedCount.text(data.count);
      }
    });
  }

  $(document).on('keydown', function (e) {
    var code = e.which ? e.which : e.keyCode;
    if (Blocker.blocked || possibleKeys.indexOf(code) === -1) {
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

  $(window).bind("message", function(e) {
    var oe = e.originalEvent, data;

    if (oe.origin !== "http://instagram.com" && oe.origin !== "https://instagram.com") { return; }

    data = JSON.parse(oe.data);
    if (data.type === 'MEASURE') {
      $("#placeholder iframe").css({height: data.details.height + 12 + "px", opacity: 1})
      $placeholder.removeClass('loading');
    }
  });
});