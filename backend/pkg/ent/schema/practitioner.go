package schema

import (
	"time"

	"entgo.io/ent"
	"entgo.io/ent/schema/edge"
	"entgo.io/ent/schema/field"
	"github.com/google/uuid"
)

type Practitioner struct {
	ent.Schema
}

func (Practitioner) Fields() []ent.Field {
	return []ent.Field{
		field.UUID("id", uuid.New()),
		field.Time("CreatedAt").Default(time.Now()),
		field.Time("UpdatedAt").Default(time.Now()),
	}
}

func (Practitioner) Edges() []ent.Edge {
	return []ent.Edge{
		edge.To("appointement", Appointement.Type),
	}
}
