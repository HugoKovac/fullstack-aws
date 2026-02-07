package domain

import (
	"time"

	"github.com/google/uuid"
)

type Appointement struct {
	ID           uuid.UUID
	CreatedAt    time.Time
	UpdatedAt    time.Time
	Time         time.Time
	Practitioner uuid.UUID
}
