  </main>

  <footer class="pm-foot">
    <strong><%=H(APP_NAME)%></strong>
    <span class="pm-foot__sep">|</span>
    <span>Version <%=H(APP_VERSION)%></span>
    <span class="pm-foot__sep">|</span>
    <span>Aplicacion web con ASP clasico y SQL Server</span>
    <span class="pm-foot__sep">|</span>
    <span><%=H(APP_TAGLINE)%></span>
  </footer>
</div>

<script>
  window.PM_QUEUE = <%=QueueJson()%>;
  window.PM_QUEUE_NAME = <%=JsStr(gQueueName)%>;
  window.PM_CAN_PLAY = <%=JsBool(IsLoggedIn())%>;
</script>

<!--#include file="player.asp" -->

<script src="<%=Base()%>assets/js/polimusic.js" defer></script>
</body>
</html>
<%
CloseConn
%>
