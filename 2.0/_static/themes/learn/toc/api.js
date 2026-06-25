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
  window.DocInsight.toc["api"] = absolutize([{"id":"spring.base","uid":"spring4d.api/spring.base","title":"Spring.Base","href":"api/spring.base/index.html"},{"id":"spring.core","uid":"spring4d.api/spring.core","title":"Spring.Core","href":"api/spring.core/index.html"},{"id":"spring.data","uid":"spring4d.api/spring.data","title":"Spring.Data","href":"api/spring.data/index.html"},{"id":"spring.data.designtime","uid":"spring4d.api/spring.data.designtime","title":"Spring.Data.Designtime","href":"api/spring.data.designtime/index.html"},{"id":"spring.extensions","uid":"spring4d.api/spring.extensions","title":"Spring.Extensions","href":"api/spring.extensions/index.html"},{"id":"spring.persistence","uid":"spring4d.api/spring.persistence","title":"Spring.Persistence","href":"api/spring.persistence/index.html"},{"id":"spring.tests","uid":"spring4d.api/spring.tests","title":"Spring.Tests","href":"api/spring.tests/index.html"}]);
})();
