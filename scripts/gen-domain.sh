#!/bin/bash
# Generate a new domain module with adapter

set -e

if [ -z "$1" ]; then
  echo "❌ Error: Domain name required"
  echo ""
  echo "Usage: pnpm gen:domain <domain-name>"
  echo ""
  echo "Example: pnpm gen:domain user-profile"
  exit 1
fi

DOMAIN_NAME=$1
DOMAIN_DIR="src/domain/$DOMAIN_NAME"
ADAPTER_FILE="src/adapters/${DOMAIN_NAME}-adapter.ts"

# Convert kebab-case to PascalCase for type names
# E.g., user-profile -> UserProfile
TYPE_NAME=$(echo "$DOMAIN_NAME" | awk -F'-' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))} 1' OFS='')

# Convert kebab-case to camelCase for variable names
# E.g., user-profile -> userProfile
CAMEL_NAME=$(echo "$DOMAIN_NAME" | awk -F'-' '{printf "%s", tolower($1); for(i=2;i<=NF;i++) printf "%s", toupper(substr($i,1,1)) tolower(substr($i,2))} END {print ""}')

# Check if domain already exists
if [ -d "$DOMAIN_DIR" ]; then
  echo "❌ Error: Domain '$DOMAIN_NAME' already exists at $DOMAIN_DIR"
  exit 1
fi

# Check if adapter already exists
if [ -f "$ADAPTER_FILE" ]; then
  echo "❌ Error: Adapter already exists at $ADAPTER_FILE"
  exit 1
fi

echo "🏗️  Generating domain: $DOMAIN_NAME"

# Create domain folder
mkdir -p "$DOMAIN_DIR"

# Create domain types file
cat > "$DOMAIN_DIR/${DOMAIN_NAME}.types.ts" << EOF
/**
 * Domain types for $DOMAIN_NAME
 * Pure TypeScript - no React imports allowed
 */

export interface ${TYPE_NAME} {
  id: string;
  // Add your fields here
}

export type ${TYPE_NAME}CreateInput = Omit<${TYPE_NAME}, 'id'>;

export type ${TYPE_NAME}UpdateInput = Partial<${TYPE_NAME}CreateInput>;
EOF

# Create domain rules file
cat > "$DOMAIN_DIR/${DOMAIN_NAME}.rules.ts" << EOF
/**
 * Business rules for $DOMAIN_NAME
 * Pure TypeScript - no React imports allowed
 */

import { ${TYPE_NAME}, ${TYPE_NAME}CreateInput } from './${DOMAIN_NAME}.types';

/**
 * Validate ${TYPE_NAME} data
 */
export function validate${TYPE_NAME}(data: unknown): ${TYPE_NAME} {
  // Add validation logic using Zod or similar
  // For now, just cast (replace with proper validation)
  return data as ${TYPE_NAME};
}

/**
 * Check if ${TYPE_NAME} is valid for creation
 */
export function canCreate${TYPE_NAME}(_data: ${TYPE_NAME}CreateInput): boolean {
  // Add business logic here
  // TODO: Implement validation rules
  return true;
}
EOF

# Create domain queries file (React Query hooks)
cat > "$DOMAIN_DIR/${DOMAIN_NAME}.queries.ts" << EOF
/**
 * React Query hooks for $DOMAIN_NAME
 * This is the only domain file that can import React hooks
 */

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { ${TYPE_NAME}Adapter } from '@adapters/${DOMAIN_NAME}-adapter';
import type { ${TYPE_NAME}CreateInput, ${TYPE_NAME}UpdateInput } from './${DOMAIN_NAME}.types';

// Query keys
export const ${CAMEL_NAME}Keys = {
  all: ['${DOMAIN_NAME}'] as const,
  lists: () => [...${CAMEL_NAME}Keys.all, 'list'] as const,
  list: (filters: string) => [...${CAMEL_NAME}Keys.lists(), { filters }] as const,
  details: () => [...${CAMEL_NAME}Keys.all, 'detail'] as const,
  detail: (id: string) => [...${CAMEL_NAME}Keys.details(), id] as const,
};

/**
 * Fetch all ${DOMAIN_NAME} items
 */
export function use${TYPE_NAME}s() {
  return useQuery({
    queryKey: ${CAMEL_NAME}Keys.lists(),
    queryFn: () => ${TYPE_NAME}Adapter.fetchAll(),
  });
}

/**
 * Fetch single ${DOMAIN_NAME} by ID
 */
export function use${TYPE_NAME}(id: string) {
  return useQuery({
    queryKey: ${CAMEL_NAME}Keys.detail(id),
    queryFn: () => ${TYPE_NAME}Adapter.fetchById(id),
    enabled: !!id,
  });
}

/**
 * Create new ${DOMAIN_NAME}
 */
export function useCreate${TYPE_NAME}() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: ${TYPE_NAME}CreateInput) => ${TYPE_NAME}Adapter.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ${CAMEL_NAME}Keys.lists() });
    },
  });
}

/**
 * Update existing ${DOMAIN_NAME}
 */
export function useUpdate${TYPE_NAME}(id: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: ${TYPE_NAME}UpdateInput) => ${TYPE_NAME}Adapter.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ${CAMEL_NAME}Keys.detail(id) });
      queryClient.invalidateQueries({ queryKey: ${CAMEL_NAME}Keys.lists() });
    },
  });
}

/**
 * Delete ${DOMAIN_NAME}
 */
export function useDelete${TYPE_NAME}() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: string) => ${TYPE_NAME}Adapter.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ${CAMEL_NAME}Keys.lists() });
    },
  });
}
EOF

# Create domain index
cat > "$DOMAIN_DIR/index.ts" << EOF
export * from './${DOMAIN_NAME}.types';
export * from './${DOMAIN_NAME}.rules';
export * from './${DOMAIN_NAME}.queries';
EOF

# Create adapter file
cat > "$ADAPTER_FILE" << EOF
/**
 * API adapter for $DOMAIN_NAME
 * Handles API calls and shape mapping (backend → frontend)
 */

import { ${TYPE_NAME}, ${TYPE_NAME}CreateInput, ${TYPE_NAME}UpdateInput } from '@domain/${DOMAIN_NAME}';
// import { apiClient } from '@/data/client';

/**
 * Backend API shape (replace with actual API response type)
 */
interface ${TYPE_NAME}ApiResponse {
  id: string;
  // Add backend fields here
}

export class ${TYPE_NAME}Adapter {
  /**
   * Map backend API response to frontend domain model
   */
  static toFrontend(backend: ${TYPE_NAME}ApiResponse): ${TYPE_NAME} {
    return {
      id: backend.id,
      // Map backend fields to frontend fields
    };
  }

  /**
   * Map frontend domain model to backend API request
   */
  static toBackend(_frontend: ${TYPE_NAME}CreateInput): Partial<${TYPE_NAME}ApiResponse> {
    return {
      // Map frontend fields to backend fields
      // TODO: Implement mapping
    };
  }

  /**
   * Fetch all ${DOMAIN_NAME} items
   */
  static async fetchAll(): Promise<${TYPE_NAME}[]> {
    // TODO: Replace with actual API call
    // const { body } = await apiClient.${DOMAIN_NAME}.getAll();
    // return body.map(this.toFrontend);

    // Mock data for now
    return [];
  }

  /**
   * Fetch single ${DOMAIN_NAME} by ID
   */
  static async fetchById(id: string): Promise<${TYPE_NAME}> {
    // TODO: Replace with actual API call
    // const { body } = await apiClient.${DOMAIN_NAME}.getById({ params: { id } });
    // return this.toFrontend(body);

    // Mock data for now
    return { id } as ${TYPE_NAME};
  }

  /**
   * Create new ${DOMAIN_NAME}
   */
  static async create(data: ${TYPE_NAME}CreateInput): Promise<${TYPE_NAME}> {
    // TODO: Replace with actual API call
    // const { body } = await apiClient.${DOMAIN_NAME}.create({ body: this.toBackend(data) });
    // return this.toFrontend(body);

    // Mock data for now
    return { id: 'new-id', ...data } as ${TYPE_NAME};
  }

  /**
   * Update existing ${DOMAIN_NAME}
   */
  static async update(id: string, data: ${TYPE_NAME}UpdateInput): Promise<${TYPE_NAME}> {
    // TODO: Replace with actual API call
    // const { body } = await apiClient.${DOMAIN_NAME}.update({
    //   params: { id },
    //   body: this.toBackend(data)
    // });
    // return this.toFrontend(body);

    // Mock data for now
    return { id, ...data } as ${TYPE_NAME};
  }

  /**
   * Delete ${DOMAIN_NAME}
   */
  static async delete(_id: string): Promise<void> {
    // TODO: Replace with actual API call
    // await apiClient.${DOMAIN_NAME}.delete({ params: { id: _id } });

    // Mock for now
    return Promise.resolve();
  }
}
EOF

echo "✅ Domain created at $DOMAIN_DIR"
echo "✅ Adapter created at $ADAPTER_FILE"
echo ""
echo "Created files:"
echo "  📁 $DOMAIN_DIR/${DOMAIN_NAME}.types.ts"
echo "  📁 $DOMAIN_DIR/${DOMAIN_NAME}.rules.ts"
echo "  📁 $DOMAIN_DIR/${DOMAIN_NAME}.queries.ts"
echo "  📁 $ADAPTER_FILE"
echo ""
echo "Next steps:"
echo "  1. Define types in ${DOMAIN_NAME}.types.ts"
echo "  2. Add business rules in ${DOMAIN_NAME}.rules.ts"
echo "  3. Update adapter with real API calls in ${DOMAIN_NAME}-adapter.ts"
echo "  4. Use hooks from ${DOMAIN_NAME}.queries.ts in components"
echo "  5. Run: pnpm check:all"
