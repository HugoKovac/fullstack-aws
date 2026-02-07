package schema

import (
	"time"

	"entgo.io/ent"
	"entgo.io/ent/schema/edge"
	"entgo.io/ent/schema/field"
	"github.com/google/uuid"
)

type Appointement struct {
	ent.Schema
}

func (Appointement) Fields() []ent.Field {
	return []ent.Field{
		field.UUID("id", uuid.New()),
		field.Time("CreatedAt").Default(time.Now()),
		field.Time("UpdatedAt").Default(time.Now()),
		field.Time("Time").Default(time.Now()),
	}
}

func (Appointement) Edges() []ent.Edge {
	return []ent.Edge{
		edge.From("practitioner", Practitioner.Type).
			Ref("appointement").
			Unique(),
	}
}
