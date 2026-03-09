# Anti-Pattern: form-validation-missing

## Problem

AI generates forms without client-side validation, or with inconsistent controlled/uncontrolled input patterns.
Forms submit invalid data, show no inline errors, and rely entirely on server-side validation for UX.

## Why It's Bad

- Users submit invalid data → wasted API calls → poor UX
- No inline feedback — user doesn't know what's wrong until server responds
- Mixed controlled/uncontrolled inputs cause React warnings and unpredictable behavior
- Missing `required`, `type`, `pattern` attributes lose built-in browser validation

## Severity

HIGH

## Detection

```bash
# Forms without onSubmit validation or form library
grep -rn "<form" src/ | grep -v "onSubmit\|@submit\|handleSubmit\|useForm"
# Inputs without validation attributes
grep -rn "<input" src/ | grep -v "required\|pattern\|minLength\|maxLength\|type="
```

## Bad Example (React)

```tsx
// ❌ No validation, uncontrolled → controlled switch
function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = async () => {
    // No validation — submits empty/invalid data
    await api.auth.login({ email, password });
  };

  return (
    <form onSubmit={handleSubmit}>
      <input onChange={(e) => setEmail(e.target.value)} />
      <input onChange={(e) => setPassword(e.target.value)} />
      <button type="submit">Login</button>
    </form>
  );
}
```

## Good Example (React)

```tsx
// ✅ Schema validation + inline errors + accessible
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const loginSchema = z.object({
  email: z.string().email('Enter a valid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
});

type LoginForm = z.infer<typeof loginSchema>;

function LoginForm() {
  const { register, handleSubmit, formState: { errors } } = useForm<LoginForm>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginForm) => {
    await api.auth.login(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} noValidate>
      <label htmlFor="email">Email</label>
      <input
        id="email"
        type="email"
        aria-describedby={errors.email ? 'email-error' : undefined}
        aria-invalid={!!errors.email}
        {...register('email')}
      />
      {errors.email && <p id="email-error" role="alert">{errors.email.message}</p>}

      <label htmlFor="password">Password</label>
      <input
        id="password"
        type="password"
        aria-describedby={errors.password ? 'password-error' : undefined}
        aria-invalid={!!errors.password}
        {...register('password')}
      />
      {errors.password && <p id="password-error" role="alert">{errors.password.message}</p>}

      <button type="submit">Login</button>
    </form>
  );
}
```

## Good Example (Vue)

```vue
<!-- ✅ VeeValidate + Zod + accessible errors -->
<script setup lang="ts">
import { useForm } from 'vee-validate';
import { toTypedSchema } from '@vee-validate/zod';
import { z } from 'zod';

const schema = toTypedSchema(z.object({
  email: z.string().email('Enter a valid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
}));

const { handleSubmit, defineField, errors } = useForm({ validationSchema: schema });

const [email, emailAttrs] = defineField('email');
const [password, passwordAttrs] = defineField('password');

const onSubmit = handleSubmit(async (values) => {
  await api.auth.login(values);
});
</script>

<template>
  <form @submit="onSubmit" novalidate>
    <label for="email">Email</label>
    <input
      id="email"
      v-model="email"
      v-bind="emailAttrs"
      type="email"
      :aria-describedby="errors.email ? 'email-error' : undefined"
      :aria-invalid="!!errors.email"
    />
    <p v-if="errors.email" id="email-error" role="alert">{{ errors.email }}</p>

    <label for="password">Password</label>
    <input
      id="password"
      v-model="password"
      v-bind="passwordAttrs"
      type="password"
      :aria-describedby="errors.password ? 'password-error' : undefined"
      :aria-invalid="!!errors.password"
    />
    <p v-if="errors.password" id="password-error" role="alert">{{ errors.password }}</p>

    <button type="submit">Login</button>
  </form>
</template>
```

## Rule

BANNED: Forms without client-side validation (no schema, no inline errors).
REQUIRED: Schema-based validation (Zod + react-hook-form / VeeValidate), inline error messages, accessible error association (`aria-describedby`, `aria-invalid`, `role="alert"`).
REQUIRED: Consistent controlled inputs — never mix controlled and uncontrolled in same form.
