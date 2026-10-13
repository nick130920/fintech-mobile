# Registration Form Usability

## Objective

Make account creation visually complete and require users to confirm their password before registration is submitted.

## Scope

- Prevent the `Crear Cuenta` button from appearing vertically clipped.
- Add a `Confirmar contraseña` field to the registration form.
- Validate that both password entries match before calling the authentication provider.
- Keep the existing backend registration payload unchanged.
- Add focused widget coverage for the new client-side behavior and button height.

## Constraints

- Preserve the existing `POST /auth/register` contract.
- Do not add confirmation data to `RegisterRequest`, `AuthProvider`, or `AuthRepository`.
- Keep the form scrollable on compact devices.
- Preserve unrelated working-tree changes.

## Delivery

- Branch: `fix/registration-form`.
- Review workload: small, one implementation work unit.
- Allowed edit surfaces:
  - `money_flow/lib/features/auth/presentation/screens/register_screen.dart`
  - `money_flow/test/features/auth/presentation/screens/register_screen_test.dart`
  - `odd/tasks/registration-form-usability.md`

## Tasks

- [x] **RF-1 — Add password confirmation and repair button sizing**
  - Added and disposed the confirmation controller.
  - Required a non-empty exact password match before registration.
  - Rendered the confirmation field after the password field.
  - Set the registration button wrapper to 56 px.
  - Added six focused widget tests, including rendered height and compact viewport coverage.
  - Added mounted guards around post-registration state updates.
  - Verification: formatter clean; scoped analyzer clean; six widget tests passed; LSP clean; `git diff --check` passed.
  - Test-first note: the initial RED attempt was blocked before test execution by a localhost proxy/WebSocket failure; GREEN was observed after bypassing proxy variables for `flutter_tester`.
  - Commit: pending.

## Acceptance Criteria

1. The registration form shows both `Contraseña` and `Confirmar contraseña`.
2. Empty or mismatched confirmation blocks registration and displays a Spanish validation message.
3. Matching passwords continue through the existing registration flow without changing its payload.
4. The `Crear Cuenta` button has a 56 px height and is not vertically clipped.
5. Focused widget tests pass.

## Progress

- Root cause confirmed: `CustomButton` defaults to 48 px while the themed button content requires more vertical space.
- The current form has only one password controller and field.
- The backend request accepts only first name, last name, email, and password; confirmation remains client-side only.
- Implementation and six focused tests are complete within the allowed edit surfaces.
- Independent verification found and prompted correction of unsafe post-await `setState` calls; final mounted guards are in place.
- Native review preflight failed safely before creating a lineage because unrelated target review status is inconsistent.
