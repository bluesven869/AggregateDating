/**
 *
 * Sky jQuery Touch Carousel
 * URL: http://www.skyplugins.com
 * Version: 1.0.2
 * Author: Sky Plugins
 * Author URL: http://www.skyplugins.com
 *
 */
var SKY = SKY || {};
SKY.Utils = {
    touchSupport: null,
    canvasSupport: null,
    transformation2dSupport: null,
    transformation3dSupport: null,
    transitionSupport: null,
    prefixedProps: [],
    hasTouchSupport: function() {
        null === this.touchSupport && (this.touchSupport = Modernizr.touch);
        return this.touchSupport
    },
    hasCanvasSupport: function() {
        null === this.canvasSupport && (this.canvasSupport = Modernizr.canvas);
        return this.canvasSupport
    },
    has2dTransformationSupport: function() {
        null === this.transformation2dSupport && (this.transformation2dSupport = Modernizr.csstransforms);
        return this.transformation2dSupport
    },
    has3dTransformationSupport: function() {
        null === this.transformation3dSupport && (this.transformation3dSupport = Modernizr.csstransforms3d);
        return this.transformation3dSupport
    },
    hasTransitionSupport: function() {
        null === this.transitionSupport && (this.transitionSupport = Modernizr.csstransitions);
        return this.transitionSupport
    },
    getPrefixedProperty: function(a) {
        void 0 === this.prefixedProps[a] && (this.prefixedProps[a] = Modernizr.prefixed(a));
        return this.prefixedProps[a]
    },
    setCursor: function(a) {

        switch (a) {
            case "openhand":
                $("body").css("cursor",
                    "url(../Images/openhand.cur), auto");
                break;
            case "closedhand":
                $("body").css("cursor", "url(../Images/closedhand.cur), auto");
                break;
            default:
                $("body").css("cursor", a)
        }
    },
    hexToRGB: function(a) {
        "#" === a[0] && (a = a.substr(1));
        if (3 == a.length) {
            var b = /^([a-f\d])([a-f\d])([a-f\d])$/i.exec(a).slice(1);
            a = "";
            for (var c = 0; 3 > c; c++) a += b[c] + b[c]
        }
        b = /^([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(a).slice(1);
        return {
            r: parseInt(b[0], 16),
            g: parseInt(b[1], 16),
            b: parseInt(b[2], 16)
        }
    }
};
window.requestAnimFrame = function() {
    return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(a) {
        window.setTimeout(a, 1E3 / 60)
    }
}();
SKY.ImageLoader = function(a) {
    this.subscribers = [];
    this.img = a;
    this.fired = !1
};
SKY.ImageLoader.prototype = {
    subscribe: function(a) {
        this.subscribers.push(a)
    },
    unsubscribe: function(a) {
        for (var b = 0; b < this.subscribers.length; b++) this.subscribers[b] === a && delete this.subscribers[b]
    },
    publish: function() {
        if (!this.fired) {
            this.fired = !0;
            for (var a = 0; a < this.subscribers.length; a++)
                if ("function" === typeof this.subscribers[a]) this.subscribers[a]()
        }
    },
    load: function() {
        var a = this;
        this.img.addEventListener ? this.img.addEventListener("load", function(b) {
            a.onLoad(b)
        }, !1) : this.img.attachEvent && this.img.attachEvent("onload",
            function(b) {
                a.onLoad(b)
            });
        if (this.img.complete || void 0 === this.img.complete || "loading" === this.img.readyState) {
            var b = this.img.src;
            this.img.src = "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw==";
            this.img.src = b
        }
    },
    onLoad: function(a) {
        1 < this.img.height && this.publish()
    }
};
SKY.Timer = function(a, b) {
    this.delay = a || 2E3;
    this.repeatCount = b || 0;
    this.currentCount = 0;
    this.intervalID = null;
    this.running = !1;
    this.subscribers = []
};
SKY.Timer.prototype = {
    subscribe: function(a) {
        this.subscribers.push(a)
    },
    unsubscribe: function(a) {
        for (var b = 0; b < this.subscribers.length; b++) this.subscribers[b] === a && delete this.subscribers[b]
    },
    publish: function(a) {
        for (var b = 0; b < this.subscribers.length; b++)
            if ("function" === typeof this.subscribers[b]) this.subscribers[b](a)
    },
    reset: function() {
        this.currentCount = 0
    },
    start: function() {
        var a = this;
        this.running || (this.intervalID = setInterval(function() {
            a.tick()
        }, this.delay), this.running = !0)
    },
    stop: function() {
        this.running &&
            (clearInterval(this.intervalID), this.running = !1)
    },
    tick: function() {
        ++this.currentCount;
        this.publish("timer");
        this.currentCount == this.repeatCount && (this.reset(), this.stop(), this.publish("timercomplete"))
    }
};
SKY.CarouselItem = function(a, b) {    
    this.element = a;
    this.carousel = b;
    this.actualWidth = b.settings.itemWidth;
    this.actualHeight = b.settings.itemHeight;
    this.scaledY = this.scaledX = this.y = this.x = 0;
    this.alpha = this.scale = 1;
    this.width = this.actualWidth;
    this.height = this.actualHeight;
    this.zIndex = this.baseOffset = 0;
    this.distance = -1;
    this.extraImageSize = this.extraItemSize = 0;
    this.url = a.children("a");
    this.imageElement = a.find("img");
    this.image = this.imageElement.get(0);
    this.content = a.children(".sc-content");
    a.children(".sc-content").hide();
    this.subscribers = {
        load: []
    };
    this.loaded = !1;
    this.reflection = null;
    this.init()
};
SKY.CarouselItem.prototype = {
    
    init: function() {
        if (!1 == $.support.leadingWhitespace) {
            var a = 2 * parseInt(this.imageElement.css("padding-left")),
                b = 2 * parseInt(this.imageElement.css("border-left-width")),
                c = 2 * parseInt(this.element.css("padding-left")),
                d = 2 * parseInt(this.element.css("border-left-width"));

            this.extraImageSize = a + b;
            this.extraItemSize = c + d
        }
        this.updateBaseOffset()
    },
    load: function() {
        var a = this;
        if (!this.loaded) {
            var b = new SKY.ImageLoader(this.image);
            b.subscribe(function() {
                a.onImageLoaded()
            });
            b.load()
        }
    },
    subscribe: function(a, b) {
        this.subscribers[a].push(b)
    },
    unsubscribe: function(a, b) {
        for (var c = 0; c < this.subscribers[a].length; c++) this.subscribers[a][c] === b && delete this.subscribers[a][c]
    },
    publish: function(a, b) {
        for (var c = 0; c < this.subscribers[a].length; c++)
            if ("function" === typeof this.subscribers[a][c]) this.subscribers[a][c](b)
    },
    index: function() {
        return this.element.index()
    },
    onImageLoaded: function() {
        var a = this.carousel.settings;
        this.carousel.settings.reflectionVisible && (this.reflection = SKY.CarouselItem.createReflection(this.imageElement,
            a.reflectionSize, a.reflectionAlpha), this.reflection.css({
            "float": "left",
            clear: "both",
            "margin-top": a.reflectionDistance + "px"
        }), this.element.append(this.reflection), this.update());
        this.loaded = !0;
        this.publish("load", this)
    },
    setAlpha: function(a) {
        a != this.alpha && (this.alpha = a, this.update())
    },
    setX: function(a) {
        a != this.x && (this.scaledX += a - this.x, this.x = a, this.update())
    },
    setY: function(a) {
        a != this.y && (this.scaledY += a - this.y, this.y = a, this.update())
    },
    setXY: function(a, b) {
        a != this.x && b != this.y && (this.scaledX += a - this.x,
            this.scaledY += b - this.y, this.x = a, this.y = b, this.update())
    },
    setScale: function(a) {
        a != this.scale && (this.scale = a, this.update())
    },
    setDistance: function(a) {
        this.distance = a
    },
    setZIndex: function(a) {
        a != this.zIndex && (this.zIndex = a, this.element.css("z-index", a))
    },
    getBaseOffset: function() {
        return this.baseOffset
    },
    updateBaseOffset: function() {
        var a = this.carousel.settings;
        this.baseOffset = this.index() * (a.itemWidth * a.unselectedItemZoomFactor + a.distance)

        
    },
    update: function() {
        var a = this.carousel.settings;
        if (SKY.Utils.has2dTransformationSupport()) 
        {
            a = "translate(" + this.x + "px, " + this.y + "px) scale(" + this.scale + ")", SKY.Utils.has3dTransformationSupport() && (a += " translateZ(0)"), this.element.css(SKY.Utils.getPrefixedProperty("transform"), a), this.element.css("opacity", this.alpha);
            
        }
        else {
            var b = this.actualWidth * this.scale,
                c = this.actualHeight * this.scale;
            this.scaledX = this.x + (this.actualWidth - b) / 2;
            this.scaledY = this.y + (this.actualHeight - c) / 2;

            this.width = b;
            this.height = c;
            b = {
                left: this.scaledX,
                top: this.scaledY,
                width: this.width - this.extraItemSize,
                height: this.height -
                    this.extraItemSize
            };
            c = {
                width: b.width - this.extraImageSize,
                height: b.height - this.extraImageSize
            };
            a.reflectionVisible && !SKY.Utils.hasCanvasSupport() ? (c.opacity = this.alpha, this.reflection && this.reflection.css({
                width: b.width,
                height: b.height,
                filter: SKY.CarouselItem.getAlphaFilterStatement(a.reflectionAlpha, a.reflectionSize, a.itemHeight)
            })) : b.opacity = this.alpha;
            this.element.css(b);
            this.imageElement.css(c)
        }
    },
    launchURL: function() {
        if (0 < this.url.length) {
            var a = this.url.attr("target");
            window.open(this.url.attr("href"),
                a ? a : "_self")
        }
    },
    addClass: function(a) {
        this.element.addClass(a)
    },
    removeClass: function(a) {
        this.element.removeClass(a)
    }
};
SKY.CarouselItem.createReflection = function(a, b, c) {
    var d = a.width(),
        g = a.height(),
        e = null;
    SKY.Utils.hasCanvasSupport() ? (e = $("<canvas>"), ctx = e.get(0).getContext("2d"), e.attr({
        width: d,
        height: b
    }), e.addClass("reflection"), ctx.save(), ctx.translate(0, g), ctx.scale(1, -1), ctx.drawImage(a.get(0), 0, 0, d, g), ctx.restore(), ctx.globalCompositeOperation = "destination-out", a = ctx.createLinearGradient(0, 0, 0, b), a.addColorStop(0, "rgba(0, 0, 0, " + (1 - c) + ")"), a.addColorStop(1, "rgba(0, 0, 0, 1.0)"), ctx.fillStyle = a, ctx.fillRect(0,
        0, d, b)) : (e = $("<img>"), e.attr({
        src: a.get(0).src
    }), e.css("filter", SKY.CarouselItem.getAlphaFilterStatement(c, b, g)));
    return e
};
SKY.CarouselItem.getAlphaFilterStatement = function(a, b, c) {
    return "flipv progid:DXImageTransform.Microsoft.Alpha(opacity=" + 100 * a + ", style=1, finishOpacity=0, startx=0, starty=0, finishx=0, finishy=" + 100 * (b / c) + ")"
};
SKY.Container = function(a, b) {
    this.element = a;
    this.carousel = b;
    this.x = 0
};
SKY.Container.prototype = {
    setX: function(a, b) {
        this.x = a;
        this.update(b)
    },
    getLeft: function() {
        return this.element.position().left
    },
    setTopMargin: function(a) {
        var b = this.carousel.settings,
            c = b.itemHeight;
        "auto" == a && (a = (this.carousel.dom.carousel.height() - c * b.selectedItemZoomFactor) / 2);
        a = -c * (1 - b.selectedItemZoomFactor) / 2 + a;
        this.element.css("margin-top", a + "px")
    },
    update: function(a) {
        var b = this;
        a ? (this.carousel.onSelectionAnimationStart(), this.element.on("webkitTransitionEnd transitionend oTransitionEnd otransitionend MSTransitionEnd", function(a) {
            b.element.off("webkitTransitionEnd transitionend oTransitionEnd otransitionend MSTransitionEnd");
            b.carousel.onSelectionAnimationEnd()
        }), SKY.Utils.hasTransitionSupport() ? (this.element.css(SKY.Utils.getPrefixedProperty("transition"), "left " + a + "s ease-out"), this.element.css("left", this.x)) : this.element.stop().animate({
            left: this.x
        }, 1E3 * a, function() {
            b.carousel.onSelectionAnimationEnd()
        })) : (SKY.Utils.hasTransitionSupport() && this.element.css(SKY.Utils.getPrefixedProperty("transition"), ""), this.element.stop().css({
            left: this.x
        }))
    }
};
SKY.Carousel = function(a, b) {    
    
    this.settings = {
        itemWidth: 300,
        itemHeight: 300,
        distance: 15,
        startIndex: "auto",
        enableKeyboard: !0,
        enableMouseWheel: !0,
        reverseMouseWheel: !1,
        autoSlideshow: !1,
        autoSlideshowDelay: 2.5,
        loop: !0,
        selectedItemDistance: 50,
        selectedItemZoomFactor: 1,
        unselectedItemZoomFactor: 0.6,
        unselectedItemAlpha: 0.6,
        motionStartDistance: 150,
        topMargin: 30,
        preload: !0,
        showPreloader: !0,
        navigationButtonsVisible: !0,
        gradientStartPoint: 0.15,
        gradientEndPoint: 1,
        gradientOverlayVisible: !0,
        gradientOverlayColor: "#fff",
        gradientOverlaySize: 215,
        reflectionVisible: !1,
        reflectionDistance: 4,
        reflectionSize: 100,
        reflectionAlpha: 0.38,
        slideSpeed: 0.3,
        selectByClick: !1
    };
    b && $.extend(this.settings, b);

    this.targetLeft = 0;
    this.dragging = this.mouseOver = !1;
    this.extraDistanceUnit = this.scaleUnit = this.alphaUnit = this.centerY = this.centerX = this.timer = this.preloader = this.contentContainer = this.container = this.closestItem = this.selectedItem = null;

    this.carouselItems = [];
    this.dom = {
        carousel: a
    };
    this.events = {};
    this.init()
};
SKY.Carousel.prototype = {
    init: function() {
        this.prev_object = -1;
        this.initDOM();
        this.initConfigParams();
        this.initEvents();
        this.initContentWrapper();
        this.initContainer();
        this.initGradientOverlays();
        this.initNavigationButtons();
        this.initResizeListener();
        this.initKeyboardNavigation();
        this.initMouseWheelSupport();
        this.initAutoSlideshow();
        this.calculateUnits();
        this.update();
        this.dom.carousel.css("visibility", "visible")
    },
    initDOM: function() {
        var a = this.settings;
        this.dom.document = $(document);
        this.dom.wrapper = this.dom.carousel.children(".sky-carousel-wrapper");
        this.dom.container = this.dom.wrapper.children(".sky-carousel-container");
        this.dom.items = this.dom.container.children("li");
        this.dom.links = this.dom.container.find("li > a");
        this.dom.images = this.dom.container.find("li img");
        this.dom.carousel.addClass("sc-no-select");
        a.preload && !1 != $.support.leadingWhitespace && (this.dom.wrapper.css({
            visibility: "hidden",
            opacity: 0
        }), a.showPreloader && (this.preloader = $('<div class="sc-preloader"></div>'), this.dom.carousel.append(this.preloader)));
        this.dom.images.each(function() {
            $(this).addClass("sc-image");
            this.ondragstart = function() {

                return !1
            }
        })
    },
    initConfigParams: function() {
        var a = this.settings,
            b = parseInt(this.dom.items.css("padding-left")),
            c = parseInt(this.dom.items.css("border-left-width")),
            d = parseInt(this.dom.images.css("padding-left")),
            g = parseInt(this.dom.images.css("border-left-width"));
        a.itemWidth += 2 * (b + c + d + g);
        a.itemHeight += 2 * (b + c + d + g);
        SKY.Utils.has2dTransformationSupport() && this.dom.items.css(SKY.Utils.getPrefixedProperty("transformOrigin"), "center " + Math.round(a.itemHeight / 2) + "px")
    },
    initEvents: function() {
        SKY.Utils.hasTouchSupport() ?
            (this.events.startEvent = "touchstart.sc", this.events.moveEvent = "touchmove.sc", this.events.endEvent = "touchend.sc", this.events.touchCancel = "touchcancel.sc") : (this.events.startEvent = "mousedown.sc", this.events.moveEvent = "mousemove.sc", this.events.endEvent = "mouseup.sc")
    },
    initContainer: function() {
        var a = this,
            b = 0;
        this.container = new SKY.Container(this.dom.container, this);
        this.dom.items.each(function(c) {
            c = new SKY.CarouselItem($(this), a);
            c.subscribe("load", function(c) {
                ++b;
                if (b == a.dom.items.length) a.onAllLoaded()
            });
            c.load();
            a.carouselItems.push(c)
        });
        this.dom.carousel.on(this.events.startEvent, function(b) {
            a.onStart(b)
        });
        SKY.Utils.hasTouchSupport() || this.dom.carousel.hover(function(b) {
            a.mouseOver = !0;
            a.updateCursor()
        }, function(b) {
            a.mouseOver = !1;
            a.updateCursor()
        });
        this.selectedItem = this.getStartItem();
        this.selectedItem.addClass("sc-selected");
        this.updatePlugin()
    },
    initGradientOverlays: function() {
        var a = this.settings;
        if (a.gradientOverlayVisible) {
            var b = this.createGradientOverlay("left", a.gradientStartPoint, a.gradientEndPoint,
                    a.gradientOverlayColor, a.gradientOverlaySize),
                a = this.createGradientOverlay("right", a.gradientStartPoint, a.gradientEndPoint, a.gradientOverlayColor, a.gradientOverlaySize);
            this.dom.carousel.append(b);
            this.dom.carousel.append(a)
        }
    },
    initContentWrapper: function() {
        var a = $('<div class="sc-content-wrapper"></div>');
        this.contentContainer = $('<div class="sc-content-container"></div>');
        this.contentContainer.append('<div class="sc-content"><h2></h2><p></p></div>');
        a.append(this.contentContainer);
        !1 != $.support.leadingWhitespace &&
            this.settings.preload && this.contentContainer.css({
                visibility: "hidden",
                opacity: 0
            });
        a.hide();
        this.dom.carousel.append(a)
    },
    initNavigationButtons: function() {
        var a = this;
        if (this.settings.navigationButtonsVisible) {
            var b = $('<a href="#" class="sc-nav-button sc-prev sc-no-select"></a>'),
                c = $('<a href="#" class="sc-nav-button sc-next sc-no-select"></a>');
            this.dom.carousel.append(b);
            this.dom.carousel.append(c);
            b.on("click", function(b) {                
                b.preventDefault();
                a.selectPrevious(a.settings.slideSpeed)
            });
            c.on("click", function(b) {
                
                b.preventDefault();
                a.selectNext(a.settings.slideSpeed)
            })
        }
    },
    initResizeListener: function() {
        var a = this;
        $(window).on("resize", function(b) {
            a.updatePlugin(b)
        })
    },
    initKeyboardNavigation: function() {
        var a = this;
        s = this.settings;
        s.enableKeyboard && this.dom.document.keydown(function(b) {
            if ("textarea" != b.target.type && "text" != b.target.type) switch (b.keyCode) {
                case 37:
                    a.selectPrevious(s.slideSpeed);
                    break;
                case 39:
                    a.selectNext(s.slideSpeed)
            }
        })
    },
    initMouseWheelSupport: function() {        
        var a = this,
            b = this.settings,
            c = this.dom.carousel.get(0);
        if (b.enableMouseWheel) {
            var d =
                function(c) {
                    var d = 0;
                    c.preventDefault ? c.preventDefault() : (c.returnValue = !1, c.cancelBubble = !0);
                    c.wheelDelta ? d = c.wheelDelta / 120 : c.detail && (d = -c.detail / 3);
                    b.reverseMouseWheel && (d *= -1);
                    0 < d ? a.selectPrevious(b.slideSpeed) : 0 > d && a.selectNext(b.slideSpeed)
                };
            c.addEventListener ? (c.addEventListener("mousewheel", d, !1), c.addEventListener("DOMMouseScroll", d, !1)) : c.attachEvent && c.attachEvent("onmousewheel", d)
        }
    },
    initAutoSlideshow: function() {
        this.settings.autoSlideshow && this.startAutoSlideshow()
    },
    startAutoSlideshow: function() {
        var a =
            this,
            b = this.settings;
        this.timer || (this.timer = new SKY.Timer(1E3 * b.autoSlideshowDelay), this.timer.subscribe(function(c) {
            a.selectedItem.index() < a.carouselItems.length - 1 ? a.selectNext(b.slideSpeed) : b.loop && a.select(a.carouselItems[0], b.slideSpeed)
        }));
        this.timer.start()
    },
    stopAutoSlideshow: function() {
        this.timer && this.timer.stop()
    },
    onClosestChanged: function(a) {
        this.setCurrentContent(a);
        this.dom.carousel.trigger({
            type: "closestItemChanged.sc",
            item: a
        })
    },
    setCurrentContent: function(a) {
        //  Add Select Code
        
        0 < a.content.length ? (this.contentContainer.find("h2").html(a.content.children("h2").html()),
            this.contentContainer.find("p").html(a.content.children("p").html())) : (this.contentContainer.find("h2").empty(), this.contentContainer.find("p").empty())
    },
    getStartItem: function() {

        var a = this.settings.startIndex;
        "auto" === a && (a = Math.round(this.carouselItems.length / 2) - 1);

        return this.carouselItems[a]
    },
    zSort: function(a) {
        var b = this.carouselItems.length;
        a.sort(function(a, b) {
            return a.distance - b.distance
        });
        for (var c = 0; c < a.length; c++) a[c].setZIndex(b), --b;
        a[0] && this.closestItem !== a[0] && (this.closestItem = a[0],
            this.onClosestChanged(this.closestItem));
        a = null
    },
    select: function(a, b) {                

        var c = this.settings;
        if(a<0)
            a = this.selectedItem
        if ("number" === typeof a) var d = this.carouselItems[a];
        else "object" === typeof a && (d = a);
        this.selectedItem && this.selectedItem.removeClass("sc-selected");

        d.addClass("sc-selected");
        this.selectedItem = d;
        c = this.selectedItem.getBaseOffset() + c.itemWidth / 2 + c.selectedItemDistance;
        this.container.setX(this.centerX - c, b);
        this.dom.carousel.trigger({
            type: "itemSelected.sc",
            item: this.selectedItem
        })
    },
    selectNext1: function(a) {
        
    },
    selectNext: function(a) {
        
        var b = this.selectedItem.index();        
        if(b == this.carouselItems.length - 1) return;
        //b == this.carouselItems.length - 1 && (b = -1);        
        this.select(b + 1, a)
    },
    selectPrevious: function(a) {
        var b = this.selectedItem.index();
        if(b == 0) return;
        //0 == b && (b = this.carouselItems.length);
        this.select(b - 1, a)
    },
    calculateUnits: function() {
        var a = this.settings;
        this.alphaUnit = (1 - a.unselectedItemAlpha) / a.motionStartDistance;
        this.scaleUnit = (a.selectedItemZoomFactor - a.unselectedItemZoomFactor) / a.motionStartDistance;
        this.extraDistanceUnit = a.selectedItemDistance / a.motionStartDistance
    },
    update: function() {

        for (var a = this, b = this.settings, c = this.container,
                d = c.getLeft(), g = [], e = 0; e < this.carouselItems.length; e++) {

            var f = this.carouselItems[e],
                h = d + f.x + b.itemWidth / 2 - this.centerX,
                k = Math.abs(h);
            if (k <= b.motionStartDistance) var p = this.calculateAlpha(k),
                l = this.calculateScale(k),
                n = this.calculateExtraDistance(k);
            else p = b.unselectedItemAlpha, l = b.unselectedItemZoomFactor, n = 0;
            k <= this.centerX && (f.setDistance(k), g.push(f));
            f.setAlpha(p);
            f.setScale(l);            
            0 < h ? f.setX(f.getBaseOffset() + 2 * b.selectedItemDistance - n) : f.setX(f.getBaseOffset() + n);
            h = k = p = l = n = null
        }
        this.zSort(g);
        this.dragging &&
            c.setX(this.targetLeft);
        window.requestAnimFrame(function() {
            a.update()
        })
    },
    updatePlugin: function() {
        var a = this.dom.carousel.width(),
            b = this.dom.carousel.height();
        this.centerX = Math.floor(a / 2);
        this.centerY = Math.floor(b / 2);
        this.updateLayout()
    },
    updateLayout: function() {
        var a = this.settings,
            b = this.selectedItem.index();
        this.container.setTopMargin(a.topMargin);
        for (var c = 0; c < this.carouselItems.length; c++) {
            var d = this.carouselItems[c],
                g = 0;

            d.updateBaseOffset();
            c == b ? g = a.selectedItemDistance : c > b && (g = 2 * a.selectedItemDistance);
            
            d.setX(d.getBaseOffset() + g);
            d.setScale(a.unselectedItemZoomFactor)
        }
        this.selectedItem.setScale(a.selectedItemZoomFactor);
        this.container.setX(this.centerX - this.selectedItem.x - a.itemWidth / 2)
    },
    updateCursor: function() {
        this.dragging ? SKY.Utils.setCursor("closedhand") : this.mouseOver ? SKY.Utils.setCursor("openhand") : SKY.Utils.setCursor("auto")
    },
    calculateAlpha: function(a) {
        return (this.settings.motionStartDistance - a) * this.alphaUnit + this.settings.unselectedItemAlpha
    },
    calculateScale: function(a) {
        return (this.settings.motionStartDistance -
            a) * this.scaleUnit + this.settings.unselectedItemZoomFactor
    },
    calculateExtraDistance: function(a) {
        return Math.ceil((this.settings.motionStartDistance - a) * this.extraDistanceUnit)
    },
    onStart: function(a) {

        function b(a) {            
            //return; 
            var b = a.originalEvent,
                c = SKY.Utils.hasTouchSupport() ? b.touches[0].clientX : a.clientX,
                g = SKY.Utils.hasTouchSupport() ? b.touches[0].clientY : a.clientY,
                r = (c - startX) / 2 + n;

            m = f - c;
            f = c;
            
            if (SKY.Utils.hasTouchSupport()) {
                if (1 < b.touches.length) {
                    q = !0;
                    return
                }
                t || (t = !0, Math.abs(g - h) > Math.abs(c - startX) + 5 ? d.isScrolling = !0 : d.isScrolling = !1);
                if (d.isScrolling) {
                    q = !0;
                    return
                }
            }
            a.preventDefault();
            r > p + 40 && (r = p + 40 + 0.2 * (r - p));
            r < l - 40 && (r = l - 40 - 0.2 * (l - r));
            d.dragging || (d.dragging = !0, d.updateCursor());
            d.targetLeft = r
        }

        function c(a) {

            var f = a.originalEvent,
                e = SKY.Utils.hasTouchSupport() ? f.changedTouches[0].clientX : a.clientX;
            a = SKY.Utils.hasTouchSupport() ? f.changedTouches[0].clientY : a.clientY;
            var f = Math.round(m / 20),
                h = d.closestItem.index();
            d.timer && d.timer.start();
            d.dom.document.off(d.events.moveEvent, b);
            d.dom.document.off(d.events.endEvent,
                c);
            d.events.touchCancel && d.dom.document.off(d.events.touchCancel, c);
            
            0 == Math.abs(startX - e) ? (e = $(document.elementFromPoint(e, a)), e.hasClass("sc-image") ? (e.parent().is("a") && (e = e.parent()), e = d.carouselItems[e.parent().index()], g.selectByClick && e !== d.selectedItem ? d.select(e, g.slideSpeed) : g.selectByClick && e === d.selectedItem && d.selectNext1(g.slideSpeed)) : g.selectByClick && d.selectNext1(g.slideSpeed)) : (0 == f && (0 < Math.abs(m) && d.closestItem.index() == d.selectedItem.index()) && (f = 0 < m ? 1 : 0 > m ? -1 : 0), h += f, h = 0 > h ? 0 : h > k -
                1 ? k - 1 : h, !u && !q && d.select(h, g.slideSpeed));
            d.dragging = !1;
            d.updateCursor()
        }
        if ("A" != a.target.nodeName) {
            var d = this,
                g = this.settings,
                e = a.originalEvent,
                f = startX = SKY.Utils.hasTouchSupport() ? e.targetTouches[0].clientX : a.clientX,
                h = SKY.Utils.hasTouchSupport() ? e.targetTouches[0].clientY : a.clientY,
                k = this.carouselItems.length,
                p = d.centerX - (g.selectedItemDistance + g.itemWidth / 2),
                l = p - (g.itemWidth * g.unselectedItemZoomFactor + g.distance) * (k - 1),
                n = this.container.getLeft(),
                m = 0,
                t = !1,
                q = !1,
                u = !1;
            this.timer && this.timer.stop();
            this.dom.document.on(this.events.moveEvent, b);
            this.dom.document.on(this.events.endEvent, c);
            if (this.events.touchCancel) this.dom.document.on(this.events.touchCancel, c);
            SKY.Utils.hasTouchSupport() ? 1 < e.touches.length && (q = !0) : a.preventDefault()
        }
    },
    onAllLoaded: function() {
        var a = this,
            b = this.settings;
        if (!1 != $.support.leadingWhitespace) {
            var c = function() {
                a.dom.wrapper.css("visibility", "visible");
                a.dom.wrapper.animate({
                    opacity: 1
                }, 700);
                a.contentContainer.css("visibility", "visible");
                a.contentContainer.animate({
                        opacity: 1
                    },
                    700)
            };
            b.preload && (b.showPreloader ? this.preloader.fadeOut(700, c) : c())
        }
    },
    on: function(a, b) {
        this.dom.carousel.on(a, null, null, b)
    },
    onSelectionAnimationStart: function() {
        this.dom.carousel.trigger({
            type: "selectionAnimationStart.sc",
            item: this.selectedItem
        })
    },
    onSelectionAnimationEnd: function() {
        this.dom.carousel.trigger({
            type: "selectionAnimationEnd.sc",
            item: this.selectedItem
        })
    },
    createGradientOverlay: function(a, b, c, d, g) {
        if (SKY.Utils.hasCanvasSupport()) {
            var e = $('<canvas class="sc-overlay" width="' + g + '" height="1"></canvas'),
                f = e.get(0).getContext("2d");
            d = SKY.Utils.hexToRGB(d);
            d.r = 255;
            d.g = 255;
            d.b = 255;
            var h = null;
            e.css("width", g + "px");
            e.addClass("sc-overlay-" + a);
            "left" == a ? h = f.createLinearGradient(0, 0, g, 0) : "right" == a && (h = f.createLinearGradient(g, 0, 0, 0));
            h.addColorStop(b, "rgba(" + d.r + ", " + d.g + ", " + d.b + ", 1.0)");
            h.addColorStop(c, "rgba(" + d.r + ", " + d.g + ", " + d.b + ", 0)");            
            f.fillStyle = h;
            f.fillRect(0, 0, g, 1);
            return e
        }
    }
};

(function(a) {
    a.fn.carousel = function(b) {
        
        var c = [];
        this.each(function() {
            var d = a(this);
            d.data("sky-carousel") || d.data("sky-carousel", new SKY.Carousel(d, b));
            /*var obj = d.data("sky-carousel");

            if(obj)
            {
                /*
                for (var i = obj.carouselItems.length; i > 0; i--) {             
                     obj.carouselItems.pop();                     
                }                
                obj.selectedItem = null;
                obj.closestItem = null;
                obj =null;
                console.log (obj)
                d.data("sky-carousel", null);
            }

            d.data("sky-carousel", new SKY.Carousel(d, b))        
            c.push(d.data("sky-carousel"))*/
            //d.data("sky-carousel") || d.data("sky-carousel", new SKY.Carousel(d, b));
            //d.data("sky-carousel", console.log ("CREATE"))
            

        });
        return 1 < c.length ? c : c[0]
    }
})(jQuery);
window.Modernizr = function(a, b, c) {
    function d(a, b) {
        return typeof a === b
    }

    function g(a, b) {
        for (var d in a) {
            var f = a[d];
            if (!~("" + f).indexOf("-") && p[f] !== c) return "pfx" == b ? f : !0
        }
        return !1
    }

    function e(a, b, f) {
        var e = a.charAt(0).toUpperCase() + a.slice(1),
            h = (a + " " + n.join(e + " ") + e).split(" ");
        if (d(b, "string") || d(b, "undefined")) b = g(h, b);
        else {
            h = (a + " " + m.join(e + " ") + e).split(" ");
            a: {
                a = h;
                for (var k in a)
                    if (e = b[a[k]], e !== c) {
                        b = !1 === f ? a[k] : d(e, "function") ? e.bind(f || b) : e;
                        break a
                    }
                b = !1
            }
        }
        return b
    }
    var f = {},
        h = b.documentElement,
        k =
        b.createElement("modernizr"),
        p = k.style,
        l = " -webkit- -moz- -o- -ms- ".split(" "),
        n = ["Webkit", "Moz", "O", "ms"],
        m = ["webkit", "moz", "o", "ms"],
        k = {},
        t = [],
        q = t.slice,
        u, w = function(a, c, d, e) {
            var f, g, k, p, l = b.createElement("div"),
                n = b.body,
                m = n || b.createElement("body");
            if (parseInt(d, 10))
                for (; d--;) k = b.createElement("div"), k.id = e ? e[d] : "modernizr" + (d + 1), l.appendChild(k);
            return f = ['&#173;<style id="smodernizr">', a, "</style>"].join(""), l.id = "modernizr", (n ? l : m).innerHTML += f, m.appendChild(l), n || (m.style.background = "", m.style.overflow =
                "hidden", p = h.style.overflow, h.style.overflow = "hidden", h.appendChild(m)), g = c(l, a), n ? l.parentNode.removeChild(l) : (m.parentNode.removeChild(m), h.style.overflow = p), !!g
        },
        x = {}.hasOwnProperty,
        v;
    !d(x, "undefined") && !d(x.call, "undefined") ? v = function(a, b) {
        return x.call(a, b)
    } : v = function(a, b) {
        return b in a && d(a.constructor.prototype[b], "undefined")
    };
    Function.prototype.bind || (Function.prototype.bind = function(a) {
        var b = this;
        if ("function" != typeof b) throw new TypeError;
        var c = q.call(arguments, 1),
            d = function() {
                if (this instanceof d) {
                    var e = function() {};
                    e.prototype = b.prototype;
                    var e = new e,
                        f = b.apply(e, c.concat(q.call(arguments)));
                    return Object(f) === f ? f : e
                }
                return b.apply(a, c.concat(q.call(arguments)))
            };
        return d
    });
    k.canvas = function() {
        var a = b.createElement("canvas");
        return !!a.getContext && !!a.getContext("2d")
    };
    k.canvastext = function() {
        return !!f.canvas && !!d(b.createElement("canvas").getContext("2d").fillText, "function")
    };
    k.touch = function() {
        var c;
        return "ontouchstart" in a || a.DocumentTouch && b instanceof DocumentTouch ? c = !0 : w(["@media (",
            l.join("touch-enabled),("), "modernizr){#modernizr{top:9px;position:absolute}}"
        ].join(""), function(a) {
            c = 9 === a.offsetTop
        }), c
    };
    k.cssanimations = function() {
        return e("animationName")
    };
    k.csstransforms = function() {
        return !!e("transform")
    };
    k.csstransforms3d = function() {
        var a = !!e("perspective");
        return a && "webkitPerspective" in h.style && w("@media (transform-3d),(-webkit-transform-3d){#modernizr{left:9px;position:absolute;height:3px;}}", function(b, c) {
            a = 9 === b.offsetLeft && 3 === b.offsetHeight
        }), a
    };
    k.csstransitions = function() {
        return e("transition")
    };
    for (var y in k) v(k, y) && (u = y.toLowerCase(), f[u] = k[y](), t.push((f[u] ? "" : "no-") + u));
    f.addTest = function(a, b) {
        if ("object" == typeof a)
            for (var d in a) v(a, d) && f.addTest(d, a[d]);
        else {
            a = a.toLowerCase();
            if (f[a] !== c) return f;
            b = "function" == typeof b ? b() : b;
            h.className += " " + (b ? "" : "no-") + a;
            f[a] = b
        }
        return f
    };
    p.cssText = "";
    return k = null, f._version = "2.6.2", f._prefixes = l, f._domPrefixes = m, f._cssomPrefixes = n, f.testProp = function(a) {
        return g([a])
    }, f.testAllProps = e, f.testStyles = w, f.prefixed = function(a, b, c) {
        return b ? e(a, b, c) :
            e(a, "pfx")
    }, h.className = h.className.replace(/(^|\s)no-js(\s|$)/, "$1$2") + (" js " + t.join(" ")), f
}(this, this.document);