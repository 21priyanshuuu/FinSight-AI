FROM node:20-slim AS deps

WORKDIR /app

# Copy everything including prisma/schema.prisma early
COPY . .

# Disable postinstall to delay Prisma until schema is available
ENV NPM_CONFIG_IGNORE_SCRIPTS=true

# Install deps
RUN npm install --legacy-peer-deps

# Run prisma generate now that schema exists
RUN npx prisma generate

# Build app
RUN npm run build

# Runtime
FROM node:20-slim AS runner
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/.next ./.next
COPY --from=deps /app/public ./public
COPY --from=deps /app/package.json ./package.json
COPY --from=deps /app/prisma ./prisma

ENV NODE_ENV=production

CMD ["npm", "start"]
