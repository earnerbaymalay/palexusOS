# Maintenance Playbook

Operations guide for running PalexusOS in production.

**Audience**: System operators, DevOps engineers, maintainers  
**Scope**: Monitoring, updates, troubleshooting, disaster recovery  

---

## Table of Contents

1. [Daily Operations](#daily-operations)
2. [Monitoring & Health Checks](#monitoring--health-checks)
3. [Updates & Patches](#updates--patches)
4. [Troubleshooting Procedures](#troubleshooting-procedures)
5. [Backup & Recovery](#backup--recovery)
6. [Capacity Planning](#capacity-planning)
7. [Performance Tuning](#performance-tuning)
8. [On-Call Runbook](#on-call-runbook)

---

## Daily Operations

### Morning Health Check (5 minutes)

```bash
#!/bin/bash
# daily_health_check.sh

echo "=== PalexusOS Daily Health Check ==="
echo ""

# 1. Check if all services running
echo "1. Service Status:"
systemctl status palexus-api || echo "⚠️  API service not running"
systemctl status palexus-worker || echo "⚠️  Worker service not running"

# 2. Check disk space
echo ""
echo "2. Disk Space:"
df -h | grep -E "^/dev|Filesystem"
if [ "$(df / | awk 'NR==2 {print $5}' | sed 's/%//')" -gt 85 ]; then
    echo "⚠️  WARNING: Disk usage > 85%"
fi

# 3. Check memory
echo ""
echo "3. Memory Usage:"
free -h | head -2

# 4. Check error logs
echo ""
echo "4. Recent Errors:"
grep -i error /var/log/palexus/*.log | tail -5 || echo "✓ No recent errors"

# 5. Run tests
echo ""
echo "5. Quick Test:"
python -m pytest tests/ -q --tb=no || echo "⚠️  Some tests failed"

echo ""
echo "=== Health check complete ==="
```

**Expected Output**:
- All services running
- Disk < 85% used
- Memory available
- No recent errors
- Tests passing

---

### Weekly Tasks (30 minutes)

```bash
# 1. Update dependencies
pip list --outdated
# Review and update if needed

# 2. Check security advisories
pip-audit
# Address any high/critical CVEs

# 3. Review logs for patterns
grep -i warning /var/log/palexus/*.log | head -20
# Look for recurring issues

# 4. Verify backups completed
ls -lh /backups/palexus-*.tar.gz | tail -7
# Should have 7 recent backups

# 5. Test disaster recovery
# See Backup & Recovery section
```

---

### Monthly Tasks (1 hour)

```bash
# 1. Full system audit
# See Security Audit Checklist in SECURITY_HARDENING.md

# 2. Capacity review
# See Capacity Planning section below

# 3. Performance analysis
# See Performance Tuning section below

# 4. Update documentation
# - Are runbooks current?
# - Are alert thresholds still valid?
# - Any new known issues?

# 5. Plan next month's maintenance window
# - Schedule updates
# - Coordinate with team
```

---

## Monitoring & Health Checks

### Key Metrics to Track

```python
# monitoring/palexus_metrics.py

class PalexusMetrics:
    """Track key metrics for PalexusOS."""
    
    def collect_metrics(self) -> dict:
        """Collect all operational metrics."""
        return {
            # Performance
            "api_latency_p95_ms": self.measure_api_latency(),
            "test_suite_duration_s": self.measure_test_duration(),
            "gate_verification_time_s": self.measure_gate_time(),
            
            # Reliability
            "uptime_percent": self.calculate_uptime(),
            "error_rate_percent": self.calculate_error_rate(),
            "test_pass_rate_percent": self.calculate_test_pass_rate(),
            
            # Resources
            "disk_used_percent": self.measure_disk_usage(),
            "memory_used_percent": self.measure_memory_usage(),
            "cpu_used_percent": self.measure_cpu_usage(),
            
            # Code Quality
            "test_count": self.count_tests(),
            "code_coverage_percent": self.measure_coverage(),
            "security_issues": self.count_security_issues(),
        }
    
    def alert_if_threshold_exceeded(self, metrics: dict) -> List[str]:
        """Generate alerts for metrics exceeding thresholds."""
        alerts = []
        
        thresholds = {
            "api_latency_p95_ms": 1000,      # API > 1 second
            "error_rate_percent": 1,          # Error rate > 1%
            "disk_used_percent": 85,          # Disk > 85%
            "memory_used_percent": 90,        # Memory > 90%
            "test_pass_rate_percent": 95,     # Test pass < 95%
        }
        
        for metric, threshold in thresholds.items():
            if metric in metrics and metrics[metric] > threshold:
                alerts.append(
                    f"⚠️  {metric}: {metrics[metric]} (threshold: {threshold})"
                )
        
        return alerts
```

### Health Check Dashboard

```bash
#!/bin/bash
# health_dashboard.sh

watch -n 60 'clear && date && echo "=== PalexusOS Health ===" && \
  echo "Services:" && systemctl status palexus-* --no-pager | grep -E "^●|Active" && \
  echo "" && echo "Resources:" && free -h | grep Mem && \
  df / | tail -1 && \
  echo "" && echo "Tests:" && \
  python -m pytest tests/ -q --tb=no 2>&1 | tail -1'
```

---

## Updates & Patches

### Security Patch Procedure

```bash
# 1. Alert: Security advisory received for dependency

# 2. Assessment (15 minutes)
pip-audit --desc | grep -A5 "CRITICAL\|HIGH"
# Determine impact on PalexusOS

# 3. Update in development environment
pip install --upgrade vulnerable-package
make test

# 4. Create patch release
git checkout -b security-patch/CVE-XXXX
# ... make changes ...
git commit -m "security: Patch CVE-XXXX in dependency"
git tag -a v0.1.1 -m "Security patch for CVE-XXXX"

# 5. Deploy to production
git push origin main v0.1.1
# ... automated CI/CD deploys ...

# 6. Verify
curl https://production.example.com/health
# Verify no errors

# 7. Communicate
# - Notify users of security patch
# - Document in CHANGELOG
# - Add to incident log
```

---

### Planned Maintenance Window

```bash
#!/bin/bash
# maintenance_window.sh

# Schedule: 2026-11-27 02:00 UTC (low-traffic window)

# 1. Notify users (24 hours before)
echo "Scheduled maintenance window Nov 27 02:00 UTC (2 hours expected)"

# 2. 15 minutes before: Enable maintenance mode
systemctl stop palexus-api
echo "Maintenance mode: ON"

# 3. During maintenance
# - Update dependencies: pip install --upgrade -e .
# - Run migrations: python manage.py migrate
# - Run tests: make test
# - Verify: python -c "from palexus import *; print('✓')"

# 4. Post-maintenance
systemctl start palexus-api
sleep 10
curl https://localhost/health || echo "⚠️  Service not responding"

# 5. Notify users (window complete)
echo "Maintenance complete. System operational."
```

---

## Troubleshooting Procedures

### "API not responding"

```bash
# 1. Check if service is running
systemctl status palexus-api

# If not running:
systemctl start palexus-api
sleep 5
systemctl status palexus-api

# 2. Check logs
journalctl -u palexus-api -n 50

# 3. Check port availability
netstat -tlnp | grep palexus

# 4. Check dependencies
python -c "from palexus import *; print('✓ All imports OK')"

# 5. If still not responding, restart
systemctl restart palexus-api
```

---

### "High memory usage"

```bash
# 1. Check what's using memory
ps aux --sort=-%mem | head -10

# 2. Check if there are memory leaks
# - Review recent code changes
# - Check if objects are being properly garbage collected

# 3. If PalexusOS process is memory hog:
# Option A: Restart service
systemctl restart palexus-api

# Option B: Increase available memory
# - See Capacity Planning section

# 4. Add monitoring
# - Set memory threshold alert (see Monitoring section)
```

---

### "Tests failing in production"

```bash
# 1. Run tests locally to verify issue
make test

# 2. Check if data is different in production
# - Export production data sample
# - Run tests against it

# 3. If production-specific:
# - Migrate data to test environment
# - Debug with real data

# 4. Fix and deploy patch
# - Create fix
# - Test thoroughly
# - Deploy as security patch (see Updates section)
```

---

## Backup & Recovery

### Backup Strategy

```bash
# Daily backups: Keep 7 days
# Weekly backups: Keep 4 weeks
# Monthly backups: Keep 12 months

#!/bin/bash
# backup.sh

BACKUP_DIR="/backups"
DATE=$(date +%Y-%m-%d_%H-%M-%S)

# 1. Backup application code
tar -czf $BACKUP_DIR/palexus-code-$DATE.tar.gz \
  --exclude=.git \
  --exclude=__pycache__ \
  --exclude=.pytest_cache \
  /home/user/palexusOS

# 2. Backup configuration
tar -czf $BACKUP_DIR/palexus-config-$DATE.tar.gz \
  /etc/palexus/ \
  /home/user/.palexus/

# 3. Backup state (if applicable)
# - Database dumps
# - Token files
# - Logs

# 4. Verify backup integrity
tar -tzf $BACKUP_DIR/palexus-code-$DATE.tar.gz > /dev/null && \
  echo "✓ Backup verified"

# 5. Cleanup old backups
find $BACKUP_DIR -name "palexus-code-*.tar.gz" -mtime +7 -delete
find $BACKUP_DIR -name "palexus-config-*.tar.gz" -mtime +7 -delete
```

---

### Disaster Recovery Procedure

```bash
#!/bin/bash
# disaster_recovery.sh
# Run this if production is unrecoverable

# 1. Stop services
systemctl stop palexus-*

# 2. Restore from backup
BACKUP="$1"  # Path to backup file

# Restore code
tar -xzf $BACKUP/palexus-code-*.tar.gz -C /

# Restore configuration
tar -xzf $BACKUP/palexus-config-*.tar.gz -C /

# 3. Verify restoration
cd /home/user/palexusOS
make test

# 4. Start services
systemctl start palexus-*
sleep 10
systemctl status palexus-*

# 5. Verify operational
curl https://localhost/health || echo "⚠️  Recovery incomplete"

# 6. Document incident
# - What happened?
# - Why did it happen?
# - What can we do better?
```

---

## Capacity Planning

### Monitor Trends

```python
# capacity/monitor.py

import json
from pathlib import Path
from datetime import datetime, timedelta

class CapacityMonitor:
    """Track capacity metrics over time."""
    
    def record_metrics(self):
        """Record current metrics."""
        metrics = {
            "timestamp": datetime.now().isoformat(),
            "disk_used_gb": self.get_disk_usage(),
            "memory_used_gb": self.get_memory_usage(),
            "api_requests_per_minute": self.get_request_rate(),
            "test_suite_duration_s": self.measure_test_duration(),
        }
        
        # Store in time-series database
        self._store_metrics(metrics)
    
    def predict_capacity_issues(self):
        """Predict when resources will be exhausted."""
        history = self._get_metrics_history(days=30)
        
        # Linear regression on disk usage
        disk_growth_per_day = self._linear_regression(
            history, "disk_used_gb"
        )
        
        # Calculate days until 90% disk
        available_gb = 1000  # Total disk
        current_gb = history[-1]["disk_used_gb"]
        threshold_gb = available_gb * 0.9
        
        days_until_threshold = (threshold_gb - current_gb) / disk_growth_per_day
        
        if days_until_threshold < 30:
            print(f"⚠️  WARNING: Disk will reach 90% in {days_until_threshold} days")
            return False
        
        return True
```

### Scaling Decisions

```
Current Metrics:
- Disk: 100 GB available, 20 GB used (20%), growing 1 GB/day
- Memory: 32 GB available, 8 GB used (25%), peak 15 GB
- CPU: Average 30%, peak 85%
- API requests: 1000/min, peak 5000/min

Projections (30 days):
- Disk: ~50 GB used (50%)
- Memory: Acceptable
- API: May hit limits during peak hours

Recommendation:
- OK for next 60 days
- Plan disk expansion for month 3
- Optimize API performance to handle peaks
```

---

## Performance Tuning

### Establish Baselines

```bash
#!/bin/bash
# performance_baseline.sh

echo "=== PalexusOS Performance Baseline ==="

# 1. API Latency
echo "API Latency (p95):"
python -m pytest tests/ -k api -v | grep -i latency

# 2. Test Suite Duration
echo "Test Suite Duration:"
time make test

# 3. Gate Verification Time
echo "Gate Verification:"
python -c "
from palexus.build.gate_registry import GateRegistry
import time

r = GateRegistry()
start = time.time()
results = r.run()
duration = time.time() - start
print(f'All gates: {duration:.2f}s')
"

# 4. Memory Usage
echo "Peak Memory Usage:"
python -m memory_profiler -m palexus.cli

# 5. Store baselines
cat > performance_baseline.json << EOF
{
  "date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "api_latency_p95_ms": 100,
  "test_suite_duration_s": 30,
  "gate_verification_s": 5,
  "peak_memory_mb": 500
}
EOF
```

### Optimization Steps

```python
# If performance degrades:

# 1. Profile the slow operation
import cProfile
import pstats

pr = cProfile.Profile()
pr.enable()

# ... slow operation ...

pr.disable()
ps = pstats.Stats(pr)
ps.sort_stats('cumulative').print_stats(10)

# 2. Identify bottleneck (usually I/O or memory)

# 3. Optimize:
# - Cache results
# - Reduce I/O operations
# - Use faster algorithms
# - Parallelize where possible

# 4. Benchmark improvement
# - Measure before/after
# - Update baseline
```

---

## On-Call Runbook

### During Incident

```
1. TRIAGE (5 min)
   - What is broken? (API, tests, infrastructure)
   - How many users affected?
   - What is the blast radius?

2. MITIGATION (15 min)
   - If obvious: restart service
   - If not: scale back traffic / enable maintenance mode
   - Notify stakeholders

3. DIAGNOSIS (30 min)
   - Check logs: journalctl -u palexus-* -n 100
   - Check metrics: dashboard/prometheus
   - Reproduce locally if possible
   - See Troubleshooting section above

4. REMEDIATION (varies)
   - Apply fix (hotfix, restart, config change)
   - Test thoroughly
   - Deploy carefully

5. COMMUNICATE
   - Update status page
   - Send user notification
   - Schedule post-incident review

6. POST-INCIDENT (within 24 hours)
   - What happened?
   - Why did it happen?
   - What could we do better?
   - Action items to prevent recurrence
```

---

### Escalation Path

```
Level 1: On-Call Engineer
- Triage incident
- Follow runbook
- If resolved: document and close
- If stuck: escalate

Level 2: Senior Engineer
- Complex diagnosis
- Code-level debugging
- Database issues
- If resolved: hand back to L1 for follow-up

Level 3: Engineering Lead
- System-wide issues
- Multiple component failures
- Requires architectural decisions
```

---

## Running the Maintenance Playbook

```bash
# Full maintenance run

#!/bin/bash
# full_maintenance.sh

set -e

echo "=== PalexusOS Full Maintenance ==="

# 1. Health check
source daily_health_check.sh

# 2. Performance baseline
source performance_baseline.sh

# 3. Capacity review
python capacity/monitor.py

# 4. Security audit
python -m bandit -r palexus/

# 5. Dependency audit
pip-audit

# 6. Backup
source backup.sh

# 7. Test suite
make test

# 8. Document findings
cat > maintenance_report_$(date +%Y-%m-%d).txt << EOF
Date: $(date)
Services: $(systemctl status palexus-* | grep Active)
Disk: $(df / | tail -1)
Memory: $(free -h | grep Mem)
Tests: $(make test 2>&1 | grep -E "passed|failed")
EOF

echo "=== Maintenance complete ==="
```

---

**Last Updated**: 2026-11-20  
**Status**: ✅ Complete maintenance guide
