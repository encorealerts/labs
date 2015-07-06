if (!String.prototype.padLeft) {
  String.prototype.padLeft = function (num, ch) {
    var
      re = new RegExp(".{" + num + "}$"),
      pad = "";
    do {
      pad += ch;
    } while(pad.length < num);
    return re.exec(pad + this)[0];
  };
}

if (!String.prototype.padRight) {
  String.prototype.padRight = function (num, ch) {
    var
      re = new RegExp("^.{" + num + "}"),
      pad = "";
    do {
      pad += ch;
    } while(pad.length < num);
    return re.exec(this + pad)[0];
  };
}

if (!Date.prototype.tomorrow){
  Date.prototype.tomorrow = function (){
    return new Date(this.getFullYear(), this.getMonth(), this.getDate() + 1);
  }
}

if (!Number.prototype.round){
  Number.prototype.round = function (decimals) {
    return Number(Math.round(this + 'e' + decimals) + 'e-' + decimals);
  }
}

if (!String.format){
  String.format = function(){
    for (var i = 0, args = arguments; i < args.length - 1; i++)
      args[0] = args[0].replace(RegExp("\\{" + i + "\\}", "gm"), args[i + 1]);
    return args[0];
  };

  String.prototype.format = function(){
    var args = Array.prototype.slice.call(arguments).reverse();
    args.push(this);
    return String.format.apply(this, args.reverse());
  }; 
}