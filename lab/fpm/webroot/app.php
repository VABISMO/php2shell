<?php
/* php2shell FPM laboratory — "suitable application operation" stand-in.
 *
 * CVE-2026-109619 on FPM: the advisories require an application operation for
 * the session cycle.  This page is the minimal one: it starts the session
 * (decoding it post-RINIT, where an OOM leaves BG(unserialize) stale across
 * requests) and reflects the session contents (the leak channel once a
 * poisoned string lands in the session data).
 */
session_start();
header('Content-Type: text/plain; charset=binary');
if (!isset($_SESSION) || !is_array($_SESSION)) {
    echo "SESSION_EMPTY\n";
    exit;
}
foreach ($_SESSION as $k => $v) {
    if (is_string($v)) {
        echo $k, "\t", $v, "\n";
    } elseif (is_scalar($v) || $v === null) {
        echo $k, "\t", var_export($v, true), "\n";
    } else {
        echo $k, "\t", serialize($v), "\n";
    }
}
echo "SESSION_END\n";
