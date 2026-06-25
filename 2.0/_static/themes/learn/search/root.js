(function () {
  const script = document.currentScript;
  const rootHref = script && script.src
    ? new URL("../../../../", script.src).href
    : new URL("./", document.baseURI).href;

  function absolutize(items) {
    return items.map((item) => {
      const next = { ...item };
      if (next.url) {
        next.url = new URL(next.url, rootHref).href;
      }
      return next;
    });
  }

  window.DocInsight = window.DocInsight || {};
  window.DocInsight.searchIndex = {
    items: absolutize([{"kind":"topic","title":"Introduction","url":"introduction.html"}])
  };
})();
