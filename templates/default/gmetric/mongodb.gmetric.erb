#!/usr/bin/python
# vim: set ts=4 sw=4 et :

from subprocess import Popen
import os, urllib2, time

try:
    import json
except ImportError:
    import simplejson as json

hasPyMongo = None
try:
    import pymongo
    hasPyMongo = True
except ImportError:
    hasPyMongo = False

GMETRIC = "/usr/bin/gmetric --name=\"%s\" --value=\"%s\" --type=\"%s\" --units=\"%s\" --group=\"mongodb\""

mongodbPort = 27017
if "MONGODB_PORT" in os.environ:
    mongodbPort = int(os.environ["MONGODB_PORT"])

class ServerStatus:
    ops_tmp_file = os.path.join("/", "tmp", "mongo-prevops")

    def __init__(self):
        self.status = self.getServerStatus()
        # call individual metrics
        for f in ["conns", "mem", "btree", "backgroundFlushing", "repl", "ops", "lock", "extra_info", "recordStats", "metrics"]:
            getattr(self, f)()

        if (hasPyMongo):
            self.stats = self.getStats()
            self.writeStats()

    def getServerStatus(self):
        raw = urllib2.urlopen("http://localhost:" + str(mongodbPort + 1000) + "/_status").read()
        return json.loads(raw)["serverStatus"]

    def getStats(self):
        c = pymongo.Connection("localhost:" + str(mongodbPort), slave_okay=True)
        stats = []

        for dbName in c.database_names():
            db = c[dbName]
            dbStats = db.command("dbstats")
            if dbStats["objects"] == 0:
                continue
            stats.append(dbStats)

        c.disconnect()
        return stats

    def writeStats(self):
        keys = { "numExtents":"extents", "objects":"objects",
                 "fileSize": "bytes", "dataSize": "bytes", "indexSize": "bytes", "storageSize": "bytes" }

        totals = {}
        totalsNoLocals = {}
        for k in keys.keys():
            totalsNoLocals[k] = 0
            totals[k] = 0

        for status in self.stats:
            dbName = status["db"]

            for k, v in keys.iteritems():
                value = status[k]
                self.callGmetric({dbName + "_" + k: (value, v)})
                totals[k] += value
                if (dbName != "local"):
                    totalsNoLocals[k] += value

        for k, v in keys.iteritems():
            self.callGmetric({"total_" + k: (totals[k], v)})
            self.callGmetric({"totalNoLocal_" + k: (totalsNoLocals[k], v)})

        self.callGmetric({"total_dataAndIndexSize" : (totals["dataSize"]+totals["indexSize"], "bytes")})
        self.callGmetric({"totalNoLocal_dataAndIndexSize" : (totalsNoLocals["dataSize"]+totalsNoLocals["indexSize"], "bytes")})

    def callGmetric(self, d):
        for k, v in d.iteritems():
            unit = None
            if (isinstance(v[0], int)):
                unit = "int32"
            elif (isinstance(v[0], float)):
                unit = "double"
            else:
                raise RuntimeError(str(v[0].__class__) + " unknown (key: " + k + ")")

            cmd = GMETRIC % ("mongodb_" + k, v[0], unit, v[1])
            Popen(cmd, shell=True)

    def conns(self):
        ss = self.status
        self.callGmetric({
            "connections" : (ss["connections"]["current"], "connections")
        })

    def btree(self):
        b = self.status["indexCounters"]
        self.callGmetric({
            "index_accesses" : (b["accesses"], "count"),
            "index_hits" : (b["hits"], "count"),
            "index_misses" : (b["misses"], "count"),
            "index_resets" : (b["resets"], "count"),
            "index_miss_ratio" : (b["missRatio"], "ratio")
        })

    def extra_info(self):
        e = self.status["extra_info"]
        self.callGmetric({
            "heap_usage_bytes": (e["heap_usage_bytes"], "count"),
            "page_faults": (e["page_faults"], "count")
        })

    def recordStats(self):
        r = self.status["recordStats"]
        self.callGmetric({
            "accesses_not_in_memory": (r["accessesNotInMemory"], "count"),
            "page_fault_exceptions_thrown": (r["pageFaultExceptionsThrown"], "count")
        })

    def metrics(self):
        m = self.status["metrics"]
        self.callGmetric({
            "metrics_document_deleted": (m["document"]["deleted"], "count"),
            "metrics_document_inserted": (m["document"]["inserted"], "count"),
            "metrics_document_returned": (m["document"]["returned"], "count"),
            "metrics_document_updated": (m["document"]["updated"], "count"),
            "metrics_operation_fastmod": (m["operation"]["fastmod"], "count"),
            "metrics_operation_idhack": (m["operation"]["idhack"], "count"),
            "metrics_operation_scan_and_order": (m["operation"]["scanAndOrder"], "count"),
            "metrics_queryexecutor_scanned": (m["queryExecutor"]["scanned"], "count"),
            "metrics_record": (m["record"]["moves"], "count")
        })

    def mem(self):
        m = self.status["mem"]
        self.callGmetric({
            "mem_resident" : (m["resident"], "MB"),
            "mem_virtual" : (m["virtual"], "MB"),
            "mem_mapped" : (m["mapped"], "MB"),
            "mem_mapped_with_journal" : (m["mappedWithJournal"], "MB")
        })

    def backgroundFlushing(self):
        f = self.status["backgroundFlushing"]
        self.callGmetric({
            "flush_average" : (f["average_ms"], "ms"),
        })

    def ops(self):
        out = {}
        cur_ops = self.status["opcounters"]

        lastChange = None
        try:
            os.stat_float_times(True)
            lastChange = os.stat(self.ops_tmp_file).st_ctime
            with open(self.ops_tmp_file, "r") as f:
                content = f.read()
                prev_ops = json.loads(content)
        except (ValueError, IOError, OSError):
            prev_ops = {}

        for k, v in cur_ops.iteritems():
            if k in prev_ops:
                name = k + "s_per_second"
                if k == "query":
                    name = "queries_per_second"

                interval = time.time() - lastChange
                if (interval <= 0.0):
                    continue
                out[name] = (max(0, float(v) - float(prev_ops[k])) / interval, "ops/s")

        with open(self.ops_tmp_file, 'w') as f:
            f.write(json.dumps(cur_ops))

        self.callGmetric(out)

    def repl(self):
        ismaster = 0;
        if (self.status["repl"]["ismaster"]):
            ismaster = 1

        self.callGmetric({
            "is_master" : (ismaster, "boolean")
        })

    def lock(self):
        self.callGmetric({
            "lock_queue_readers" : (self.status["globalLock"]["currentQueue"]["readers"], "queue size"),
            "lock_queue_writers" : (self.status["globalLock"]["currentQueue"]["writers"], "queue size")
        })

if __name__ == "__main__":
    ServerStatus()
