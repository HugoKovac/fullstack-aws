package domain

import (
	"time"

	"github.com/google/uuid"
)

type Practitioner struct {
	ID        uuid.UUID
	CreatedAt time.Time
	UpdatedAt time.Time
}
