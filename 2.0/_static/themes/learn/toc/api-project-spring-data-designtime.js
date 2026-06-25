(function () {
  const script = document.currentScript;
  const rootHref = script && script.src
    ? new URL("../../../../", script.src).href
    : new URL("./", document.baseURI).href;

  function absolutize(items) {
    return items.map((item) => {
      const next = { ...item };
      if (next.href) {
        next.href = new URL(next.href, rootHref).href;
      }
      if (next.children) {
        next.children = absolutize(next.children);
      }
      return next;
    });
  }

  window.DocInsight = window.DocInsight || {};
  window.DocInsight.toc = window.DocInsight.toc || {};
  window.DocInsight.toc["api:project/spring.data.designtime"] = absolutize([{"id":"spring.data.designtime","uid":"spring4d.api/spring.data.designtime","title":"Spring.Data.Designtime","href":"api/spring.data.designtime/index.html","children":[{"id":"spring.data.registration","uid":"spring4d.api/spring.data.registration","title":"Spring.Data.Registration","href":"api/spring.data.registration/index.html","children":[{"id":"spring.data.registration-Routines","title":"Routines","children":[{"id":"spring.data.registration/register","uid":"spring4d.api/spring.data.registration/register","title":"Register","href":"api/spring.data.registration/register.html"}]}]}]}]);
})();
