# PROSALES HRMS — Launch acceptance checklist

**Target:** 30 November 2026 launch; employees begin 1 December 2026.
**Status:** NOT production-approved. Changes on development branch must be reviewed and deployed separately.

## Blockers: verify in Supabase first

- [ ] Run `supabase_launch_security_audit.sql` in the correct Supabase project. Save and review output. This is read-only.
- [ ] Confirm `verify_office_gps`, `office_check_in`, and `office_check_out` enforce **100 metres from the correct office coordinates on the server**; 50 metres in the browser is **GPS accuracy**, not office radius.
- [ ] Confirm office attendance RPCs identify the employee using the authenticated session; reject spoofed employee IDs, non-employees, invalid coordinates and inaccurate GPS.
- [ ] Confirm check-in rules: 10:45–10:59 on time, after 10:59 late, after 12:00 half-day; check-out 18:15–18:30. Confirm behaviour outside windows and for duplicate actions.
- [ ] Confirm leave approval RPC `approval_review_leave` exists, verifies HR/authorized approver server-side, updates request status, and marks approved dates correctly in attendance without overwriting valid existing check-ins.
- [ ] Confirm attendance approval RPC `review_attendance_request` exists and supports late, half-day and remote requests. Verify rejection does not mark attendance.
- [ ] Confirm `can_approve_requests` returns true only for authorized approvers; specifically verify Suprabhat's intended scope.
- [ ] Confirm RLS is enabled and policies isolate employee attendance, leave, salary and targets. Check viewer salary visibility against the latest HR policy; don't infer it from hidden UI controls.
- [ ] Verify all expected SQL tables, columns, functions and execute grants exist in the live database.

## Functional acceptance tests (use test accounts)

- [ ] Employee: log in, view own profile, own salary (where enabled), targets, leave and attendance; cannot read another employee's records.
- [ ] Employee: office GPS pass inside 100m; fail outside 100m; fail poor accuracy; check-in and check-out recorded once each.
- [ ] Employee: submit leave, late, half-day and remote requests; see Pending, Approved and Rejected status.
- [ ] HR: see all 11 employee profiles, attendance and requests; approve and reject each request type.
- [ ] Suprabhat: verify exactly the approved permissions, including remote approval, without unintended editing or salary access.
- [ ] Viewer: read-only access; cannot create/update/delete employees, salaries, targets or approvals.
- [ ] HR: daily/weekly/monthly targets and achievements, amounts and sales counts, correct employee filtering.
- [ ] Test on Android mobile browser, location permissions denied, GPS unavailable, poor network, logout/re-login, and session expiry.

## Release steps

- [ ] Resolve the development pull request and review the actual diff.
- [ ] Confirm the JavaScript parses successfully and no console errors remain.
- [ ] Deploy only after backend verification; confirm live URL and HTTPS.
- [ ] Re-run the full acceptance test on the **live** site.
- [ ] Confirm employee credentials and backup/support contact before 1 December.

**Note:** Passing frontend checks alone is not proof of Supabase authorization or 100m enforcement. No live database tests have been performed by this checklist.
